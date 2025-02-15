/+
## Guide for Slice/BLAS contributors

1. Make sure functions are
       a. inlined(!),
       b. `@nogc`,
       c. `nothrow`,
       d. `pure`.
    For this reason, it is preferable to use _simple_ `assert`s with messages
    that can be computed at compile time.
    The goals are:
        1. to reduce executable size for _any_ compilation mode
        2. to reduce template bloat in object files
        3. to reduce compilation time
        4. to allow users to write extern C bindings for code libraries on `Slice` type.

2. `std.format`, `std.string`, and `std.conv` should not be used in error
    message formatting.`"Use" ~ Concatenation.stringof`.

3. `mixin template`s may be used for pretty error message formatting.

4. `Exception`s/`enforce`s should no be used to check indices and lengths.
    Exceptions are only allowed for algorithms where validation of input data is
    too complicated for the user. `reshape` function is a good example of a case
    where Exceptions are required.
    If a function might throw an exception, an example with exception handing should be added.

5.  For simple checks like matrix transposition, compile time flags should not be used.
    It is much better to opt for runtime matrix transposition.
    Furthermore, Slice type provides runtime matrix transposition out of the box.

6.  _Fortran_VS_C_ flags should not be used. They are about notation,
    but not about the algorithm itself. For math world users,
    a corresponding code example might be included in the documentation.
    `transposed` / `everted` can be used in cache-friendly codes.

7. Compile time evaluation should not be used to produce dummy types like `IdentityMatrix`.

8. Memory allocation and algorithm logic should be separated whenever possible.

9. CTFE version(mir_ndslice_test) unittests should be added to new functions.
+/

/**
$(H1 Multidimensional Random Access Ranges)

The package provides a multidimensional array implementation.
It would be well suited to creating machine learning and image
processing algorithms, but should also be general enough for use anywhere with
homogeneously-typed multidimensional data.
In addition, it includes various functions for iteration, accessing, and manipulation.

Quick_Start:
$(SUBREF slice, sliced) is a function designed to create
a multidimensional view over a range.
Multidimensional view is presented by $(SUBREF slice, Slice) type.

------
import mir.ndslice;

auto matrix = slice!double(3, 4);
matrix[] = 0;
matrix.diagonal[] = 1;

auto row = matrix[2];
row[3] = 6;
assert(matrix[2, 3] == 6); // D & C index order
------

Note:
In many examples $(REF iota, mir,_ndslice,topology) is used
instead of a regular array, which makes it
possible to carry out tests without memory allocation.

$(SCRIPT inhibitQuickIndex = 1;)

$(DIVC quickindex,
$(BOOKTABLE,

$(TR $(TH Submodule) $(TH Declarations))

$(TR $(TDNW $(SUBMODULE slice) $(BR)
        $(SMALL $(SUBREF slice, Slice) structure
            $(BR) Basic constructors))
     $(TD
        $(SUBREF slice, Canonical)
        $(SUBREF slice, Contiguous)
        $(SUBREF slice, DeepElementType)
        $(SUBREF slice, isSlice)
        $(SUBREF slice, kindOf)
        $(SUBREF slice, Slice)
        $(SUBREF slice, sliced)
        $(SUBREF slice, slicedField)
        $(SUBREF slice, slicedNdField)
        $(SUBREF slice, SliceKind)
        $(SUBREF slice, Structure)
        $(SUBREF slice, Universal)
    )
)

$(TR $(TDNW $(SUBMODULE allocation) $(BR)
        $(SMALL Allocation utilities))
     $(TD
        $(SUBREF allocation, bitRcslice)
        $(SUBREF allocation, bitSlice)
        $(SUBREF allocation, makeNdarray)
        $(SUBREF allocation, makeSlice)
        $(SUBREF allocation, makeUninitSlice)
        $(SUBREF allocation, mininitRcslice)
        $(SUBREF allocation, ndarray)
        $(SUBREF allocation, rcslice)
        $(SUBREF allocation, shape)
        $(SUBREF allocation, slice)
        $(SUBREF allocation, stdcFreeAlignedSlice)
        $(SUBREF allocation, stdcFreeSlice)
        $(SUBREF allocation, stdcSlice)
        $(SUBREF allocation, stdcUninitAlignedSlice)
        $(SUBREF allocation, stdcUninitSlice)
        $(SUBREF allocation, uninitAlignedSlice)
        $(SUBREF allocation, uninitSlice)
    )
)

$(TR $(TDNW $(SUBMODULE topology) $(BR)
        $(SMALL Subspace manipulations
            $(BR) Advanced constructors
            $(BR) SliceKind conversion utilities))
     $(TD
        $(SUBREF topology, alongDim)
        $(SUBREF topology, as)
        $(SUBREF topology, asKindOf)
        $(SUBREF topology, assumeCanonical)
        $(SUBREF topology, assumeContiguous)
        $(SUBREF topology, assumeHypercube)
        $(SUBREF topology, assumeSameShape)
        $(SUBREF topology, bitpack)
        $(SUBREF topology, bitwise)
        $(SUBREF topology, blocks)
        $(SUBREF topology, byDim)
        $(SUBREF topology, bytegroup)
        $(SUBREF topology, cached)
        $(SUBREF topology, cachedGC)
        $(SUBREF topology, canonical)
        $(SUBREF topology, cartesian)
        $(SUBREF topology, chopped)
        $(SUBREF topology, cycle)
        $(SUBREF topology, diagonal)
        $(SUBREF topology, diff)
        $(SUBREF topology, dropBorders)
        $(SUBREF topology, evertPack)
        $(SUBREF topology, flattened)
        $(SUBREF topology, indexed)
        $(SUBREF topology, iota)
        $(SUBREF topology, ipack)
        $(SUBREF topology, kronecker)
        $(SUBREF topology, linspace)
        $(SUBREF topology, magic)
        $(SUBREF topology, map)
        $(SUBREF topology, member)
        $(SUBREF topology, ndiota)
        $(SUBREF topology, orthogonalReduceField)
        $(SUBREF topology, pack)
        $(SUBREF topology, pairwise)
        $(SUBREF topology, repeat)
        $(SUBREF topology, reshape)
        $(SUBREF topology, ReshapeError)
        $(SUBREF topology, retro)
        $(SUBREF topology, slide)
        $(SUBREF topology, slideAlong)
        $(SUBREF topology, squeeze)
        $(SUBREF topology, stairs)
        $(SUBREF topology, stride)
        $(SUBREF topology, subSlices)
        $(SUBREF topology, triplets)
        $(SUBREF topology, universal)
        $(SUBREF topology, unsqueeze)
        $(SUBREF topology, unzip)
        $(SUBREF topology, vmap)
        $(SUBREF topology, windows)
        $(SUBREF topology, zip)
    )
)

$(TR $(TDNW $(SUBMODULE filling) $(BR)
    $(SMALL Specialized initialisation routines))
     $(TD
        $(SUBREF filling, fillVandermonde)
    )
)

$(TR $(TDNW $(SUBMODULE fuse) $(BR)
    $(SMALL Data fusing (stacking)
        $(BR) See also $(SUBMODULE concatenation) submodule.
    ))
     $(TD
        $(SUBREF fuse, fuse)
        $(SUBREF fuse, fuseAs)
        $(SUBREF fuse, rcfuse)
        $(SUBREF fuse, rcfuseAs)
        $(SUBREF fuse, fuseCells)
    )
)

$(TR $(TDNW $(SUBMODULE concatenation) $(BR)
    $(SMALL Concatenation, padding, and algorithms
        $(BR) See also $(SUBMODULE fuse) submodule.
    ))
     $(TD
        $(SUBREF concatenation, forEachFragment)
        $(SUBREF concatenation, isConcatenation)
        $(SUBREF concatenation, pad)
        $(SUBREF concatenation, padEdge)
        $(SUBREF concatenation, padWrap)
        $(SUBREF concatenation, padSymmetric)
        $(SUBREF concatenation, concatenation)
        $(SUBREF concatenation, Concatenation)
        $(SUBREF concatenation, concatenationDimension)
        $(SUBREF concatenation, until)
    )
)

$(TR $(TDNW $(SUBMODULE dynamic)
        $(BR) $(SMALL Dynamic dimension manipulators))
     $(TD
        $(SUBREF dynamic, allReversed)
        $(SUBREF dynamic, dropToHypercube)
        $(SUBREF dynamic, everted)
        $(SUBREF dynamic, normalizeStructure)
        $(SUBREF dynamic, reversed)
        $(SUBREF dynamic, rotated)
        $(SUBREF dynamic, strided)
        $(SUBREF dynamic, swapped)
        $(SUBREF dynamic, transposed)
    )
)

$(TR $(TDNW $(SUBMODULE sorting)
        $(BR) $(SMALL Sorting utilities))
     $(TD
        $(SUBREF sorting, sort)
        Examples for `isSorted`, `isStrictlyMonotonic`, `makeIndex`, and `schwartzSort`.
    )
)

$(TR $(TDNW $(SUBMODULE mutation)
        $(BR) $(SMALL Mutation utilities))
     $(TD
        $(SUBREF mutation, copyMinor)
        $(SUBREF mutation, reverseInPlace)
    )
)

$(TR $(TDNW $(SUBMODULE iterator)
        $(BR) $(SMALL Declarations))
     $(TD
        $(SUBREF iterator, BytegroupIterator)
        $(SUBREF iterator, CachedIterator)
        $(SUBREF iterator, ChopIterator)
        $(SUBREF iterator, FieldIterator)
        $(SUBREF iterator, FlattenedIterator)
        $(SUBREF iterator, IndexIterator)
        $(SUBREF iterator, IotaIterator)
        $(SUBREF iterator, MapIterator)
        $(SUBREF iterator, MemberIterator)
        $(SUBREF iterator, RetroIterator)
        $(SUBREF iterator, SliceIterator)
        $(SUBREF iterator, SlideIterator)
        $(SUBREF iterator, StairsIterator)
        $(SUBREF iterator, StrideIterator)
        $(SUBREF iterator, SubSliceIterator)
        $(SUBREF iterator, Triplet)
        $(SUBREF iterator, TripletIterator)
        $(SUBREF iterator, ZipIterator)
    )
)

$(TR $(TDNW $(SUBMODULE field)
        $(BR) $(SMALL Declarations))
     $(TD
        $(SUBREF field, BitField)
        $(SUBREF field, BitpackField)
        $(SUBREF field, CycleField)
        $(SUBREF field, LinspaceField)
        $(SUBREF field, MagicField)
        $(SUBREF field, MapField)
        $(SUBREF field, ndIotaField)
        $(SUBREF field, OrthogonalReduceField)
        $(SUBREF field, RepeatField)
    )
)

$(TR $(TDNW $(SUBMODULE ndfield)
        $(BR) $(SMALL Declarations))
     $(TD
        $(SUBREF ndfield, Cartesian)
        $(SUBREF ndfield, Kronecker)
    )
)

$(TR $(TDNW $(SUBMODULE chunks)
        $(BR) $(SMALL Declarations))
     $(TD
        $(SUBREF field, chunks)
        $(SUBREF field, Chunks)
        $(SUBREF field, isChunks)
        $(SUBREF field, popFrontTuple)
    )
)

$(TR $(TDNW $(SUBMODULE traits)
        $(BR) $(SMALL Declarations))
     $(TD
        $(SUBREF traits, isIterator)
        $(SUBREF traits, isVector)
        $(SUBREF traits, isMatrix)
        $(SUBREF traits, isContiguousSlice)
        $(SUBREF traits, isCanonicalSlice)
        $(SUBREF traits, isUniversalSlice)
        $(SUBREF traits, isContiguousVector)
        $(SUBREF traits, isUniversalVector)
        $(SUBREF traits, isContiguousMatrix)
        $(SUBREF traits, isCanonicalMatrix)
        $(SUBREF traits, isUniversalMatrix)
    )
)

))

$(H2 Example: Image Processing)

A median filter is implemented as an example. The function
`movingWindowByChannel` can also be used with other filters that use a sliding
window as the argument, in particular with convolution matrices such as the
$(LINK2 https://en.wikipedia.org/wiki/Sobel_operator, Sobel operator).

`movingWindowByChannel` iterates over an image in sliding window mode.
Each window is transferred to a `filter`, which calculates the value of the
pixel that corresponds to the given window.

This function does not calculate border cases in which a window overlaps
the image partially. However, the function can still be used to carry out such
calculations. That can be done by creating an amplified image, with the edges
reflected from the original image, and then applying the given function to the
new file.

Note: You can find the example at
$(LINK2 https://github.com/libmir/mir/blob/master/examples/median_filter.d, GitHub).

-------
/++
Params:
    filter = unary function. Dimension window 2D is the argument.
    image = image dimensions `(h, w, c)`,
        where с is the number of channels in the image
    nr = number of rows in the window
    nс = number of columns in the window

Returns:
    image dimensions `(h - nr + 1, w - nc + 1, c)`,
        where с is the number of channels in the image.
        Dense data layout is guaranteed.
+/
Slice!(ubyte*, 3) movingWindowByChannel
(Slice!(Universal, [3], ubyte*) image, size_t nr, size_t nc, ubyte delegate(Slice!(Universal, [2], ubyte*)) filter)
{
        // 0. 3D
        // The last dimension represents the color channel.
    return image
        // 1. 2D composed of 1D
        // Packs the last dimension.
        .pack!1
        // 2. 2D composed of 2D composed of 1D
        // Splits image into overlapping windows.
        .windows(nr, nc)
        // 3. 5D
        // Unpacks the windows.
        .unpack
        .transposed!(0, 1, 4)
        // 4. 5D
        // Brings the color channel dimension to the third position.
        .pack!2
        // 2D to pixel lazy conversion.
        .map!filter
        // Creates the new image. The only memory allocation in this function.
        .slice;
}
-------

A function that calculates the value of iterator median is also necessary.

-------
/++

Params:
    r = input range
    buf = buffer with length no less than the number of elements in `r`
Returns:
    median value over the range `r`
+/
T median(Range, T)(Slice!(Universal, [2], Range) sl, T[] buf)
{
    import std.algorithm.sorting : topN;
    // copy sl to the buffer
    auto retPtr = reduce!(
        (ptr, elem) { *ptr = elem; return ptr + 1;} )(buf.ptr, sl);
    auto n = retPtr - buf.ptr;
    buf[0 .. n].topN(n / 2);
    return buf[n / 2];
}
-------

The `main` function:

-------
void main(string[] args)
{
    import std.conv : to;
    import std.getopt : getopt, defaultGetoptPrinter;
    import std.path : stripExtension;

    uint nr, nc, def = 3;
    auto helpInformation = args.getopt(
        "nr", "number of rows in window, default value is " ~ def.to!string, &nr,
        "nc", "number of columns in window, default value is equal to nr", &nc);
    if (helpInformation.helpWanted)
    {
        defaultGetoptPrinter(
            "Usage: median-filter [<options...>] [<file_names...>]\noptions:",
            helpInformation.options);
        return;
    }
    if (!nr) nr = def;
    if (!nc) nc = nr;

    auto buf = new ubyte[nr * nc];

    foreach (name; args[1 .. $])
    {
        import imageformats; // can be found at code.dlang.org

        IFImage image = read_image(name);

        auto ret = image.pixels
            .sliced(cast(size_t)image.h, cast(size_t)image.w, cast(size_t)image.c)
            .movingWindowByChannel
                !(window => median(window, buf))
                 (nr, nc);

        write_image(
            name.stripExtension ~ "_filtered.png",
            ret.length!1,
            ret.length!0,
            (&ret[0, 0, 0])[0 .. ret.elementCount]);
    }
}
-------

This program works both with color and grayscale images.

-------
$ median-filter --help
Usage: median-filter [<options...>] [<file_names...>]
options:
     --nr number of rows in window, default value is 3
     --nc number of columns in window default value equals to nr
-h --help This help information.
-------

$(H2 Compared with `numpy.ndarray`)

numpy is undoubtedly one of the most effective software packages that has
facilitated the work of many engineers and scientists. However, due to the
specifics of implementation of Python, a programmer who wishes to use the
functions not represented in numpy may find that the built-in functions
implemented specifically for numpy are not enough, and their Python
implementations work at a very low speed. Extending numpy can be done, but
is somewhat laborious as even the most basic numpy functions that refer
directly to `ndarray` data must be implemented in C for reasonable performance.

At the same time, while working with `ndslice`, an engineer has access to the
whole set of standard D library, so the functions he creates will be as
efficient as if they were written in C.


License: $(HTTP www.apache.org/licenses/LICENSE-2.0, Apache-2.0)
Copyright: 2020 Ilya Yaroshenko, Kaleidic Associates Advisory Limited, Symmetry Investments
Authors: Ilya Yaroshenko
Acknowledgements: John Loughran Colvin

Macros:
SUBMODULE = $(MREF_ALTTEXT $1, mir, ndslice, $1)
SUBREF = $(REF_ALTTEXT $(TT $2), $2, mir, ndslice, $1)$(NBSP)
T2=$(TR $(TDNW $(LREF $1)) $(TD $+))
TDNW2 = <td class="donthyphenate nobr" rowspan="2">$0</td>
*/
module mir.ndslice;

public import mir.algorithm.iteration;
public import mir.ndslice.allocation;
public import mir.ndslice.chunks;
public import mir.ndslice.concatenation;
public import mir.ndslice.dynamic;
public import mir.ndslice.field;
public import mir.ndslice.filling;
public import mir.ndslice.fuse;
public import mir.ndslice.iterator;
public import mir.ndslice.mutation;
public import mir.ndslice.ndfield;
public import mir.ndslice.slice;
public import mir.ndslice.topology;
public import mir.ndslice.traits;


version(mir_ndslice_test) unittest
{
    auto matrix = new double[12].sliced(3, 4);
    matrix[] = 0;
    matrix.diagonal[] = 1;

    auto row = matrix[2];
    row[3] = 6;
    assert(matrix[2, 3] == 6); // D & C index order
    //assert(matrix(3, 2) == 6); // Math & Fortran index order
}

// relaxed example
version(mir_ndslice_test) unittest
{
    import mir.qualifier;

    static Slice!(ubyte*, 3) movingWindowByChannel
    (Slice!(ubyte*, 3, Universal) image, size_t nr, size_t nc, ubyte delegate(LightConstOf!(Slice!(ubyte*, 2, Universal))) filter)
    {
        return image
            .pack!1
            .windows(nr, nc)
            .unpack
            .unpack
            .transposed!(0, 1, 4)
            .pack!2
            .map!filter
            .slice;
    }

    static T median(Iterator, T)(Slice!(Iterator,  2, Universal) sl, T[] buf)
    {
        import std.algorithm.sorting : topN;
        // copy sl to the buffer
        auto retPtr = reduce!(
            (ptr, elem) {
                *ptr = elem;
                return ptr + 1;
            } )(buf.ptr, sl);
        auto n = retPtr - buf.ptr;
        buf[0 .. n].topN(n / 2);
        return buf[n / 2];
    }

    import std.conv : to;
    import std.getopt : getopt, defaultGetoptPrinter;
    import std.path : stripExtension;

    auto args = ["std"];
    uint nr, nc, def = 3;
    auto helpInformation = args.getopt(
        "nr", "number of rows in window, default value is " ~ def.to!string, &nr,
        "nc", "number of columns in window default value equals to nr", &nc);
    if (helpInformation.helpWanted)
    {
        defaultGetoptPrinter(
            "Usage: median-filter [<options...>] [<file_names...>]\noptions:",
            helpInformation.options);
        return;
    }
    if (!nr) nr = def;
    if (!nc) nc = nr;

    auto buf = new ubyte[nr * nc];

    foreach (name; args[1 .. $])
    {
        auto ret =
            movingWindowByChannel
                 (new ubyte[300].sliced(10, 10, 3).universal, nr, nc, window => median(window, buf));
    }
}

@safe @nogc pure nothrow version(mir_ndslice_test) unittest
{
    immutable r = 1000.iota;

    auto t0 = r.sliced(1000);
    assert(t0.front == 0);
    assert(t0.back == 999);
    assert(t0[9] == 9);

    auto t1 = t0[10 .. 20];
    assert(t1.front == 10);
    assert(t1.back == 19);
    assert(t1[9] == 19);

    t1.popFront();
    assert(t1.front == 11);
    t1.popFront();
    assert(t1.front == 12);

    t1.popBack();
    assert(t1.back == 18);
    t1.popBack();
    assert(t1.back == 17);

    assert(t1 == iota([6], 12));
}

pure nothrow version(mir_ndslice_test) unittest
{
    import mir.ndslice.topology : iota;
    import mir.array.allocation : array;
    auto r = 1000.iota.array;

    auto t0 = r.sliced(1000);
    assert(t0.length == 1000);
    assert(t0.front == 0);
    assert(t0.back == 999);
    assert(t0[9] == 9);

    auto t1 = t0[10 .. 20];
    assert(t1.front == 10);
    assert(t1.back == 19);
    assert(t1[9] == 19);

    t1.popFront();
    assert(t1.front == 11);
    t1.popFront();
    assert(t1.front == 12);

    t1.popBack();
    assert(t1.back == 18);
    t1.popBack();
    assert(t1.back == 17);

    assert(t1 == iota([6], 12));

    t1.front = 13;
    assert(t1.front == 13);
    t1.front++;
    assert(t1.front == 14);
    t1.front += 2;
    assert(t1.front == 16);
    t1.front = 12;
    assert((t1.front = 12) == 12);

    t1.back = 13;
    assert(t1.back == 13);
    t1.back++;
    assert(t1.back == 14);
    t1.back += 2;
    assert(t1.back == 16);
    t1.back = 12;
    assert((t1.back = 12) == 12);

    t1[3] = 13;
    assert(t1[3] == 13);
    t1[3]++;
    assert(t1[3] == 14);
    t1[3] += 2;
    assert(t1[3] == 16);
    t1[3] = 12;
    assert((t1[3] = 12) == 12);

    t1[3 .. 5] = 100;
    assert(t1[2] != 100);
    assert(t1[3] == 100);
    assert(t1[4] == 100);
    assert(t1[5] != 100);

    t1[3 .. 5] += 100;
    assert(t1[2] <  100);
    assert(t1[3] == 200);
    assert(t1[4] == 200);
    assert(t1[5] <  100);

    --t1[3 .. 5];

    assert(t1[2] <  100);
    assert(t1[3] == 199);
    assert(t1[4] == 199);
    assert(t1[5] <  100);

    --t1[];
    assert(t1[3] == 198);
    assert(t1[4] == 198);

    t1[] += 2;
    assert(t1[3] == 200);
    assert(t1[4] == 200);

    t1[].opIndexOpAssign!"*"(t1);
    assert(t1[3] == 40000);
    assert(t1[4] == 40000);


    assert(&t1[$ - 1] is &(t1.back()));
}

@safe @nogc pure nothrow version(mir_ndslice_test) unittest
{
    import std.range : iota;
    auto r = (10_000L * 2 * 3 * 4).iota;

    auto t0 = r.slicedField(10, 20, 30, 40);
    assert(t0.length == 10);
    assert(t0.length!0 == 10);
    assert(t0.length!1 == 20);
    assert(t0.length!2 == 30);
    assert(t0.length!3 == 40);
}

pure nothrow version(mir_ndslice_test) unittest
{
    auto tensor = new int[3 * 4 * 8].sliced(3, 4, 8);
    assert(&(tensor.back.back.back()) is &tensor[2, 3, 7]);
    assert(&(tensor.front.front.front()) is &tensor[0, 0, 0]);
}

pure nothrow version(mir_ndslice_test) unittest
{
    auto slice = new int[24].sliced(2, 3, 4);
    auto r0 = slice.pack!1[1, 2];
    slice.pack!1[1, 2][] = 4;
    auto r1 = slice[1, 2];
    assert(slice[1, 2, 3] == 4);
}

pure nothrow version(mir_ndslice_test) unittest
{
    auto ar = new int[3 * 8 * 9];

    auto tensor = ar.sliced(3, 8, 9);
    tensor[0, 1, 2] = 4;
    tensor[0, 1, 2]++;
    assert(tensor[0, 1, 2] == 5);
    tensor[0, 1, 2]--;
    assert(tensor[0, 1, 2] == 4);
    tensor[0, 1, 2] += 2;
    assert(tensor[0, 1, 2] == 6);

    auto matrix = tensor[0 .. $, 1, 0 .. $];
    matrix[] = 10;
    assert(tensor[0, 1, 2] == 10);
    assert(matrix[0, 2] == tensor[0, 1, 2]);
    assert(&matrix[0, 2] is &tensor[0, 1, 2]);
}

version(mir_ndslice_test)
pure nothrow
unittest
{
    auto x = iota(2, 3);
    auto y = iota([2, 3], 1);
    auto combine1 = x.zip(y).map!"b";
    auto combine2 = x.zip(y).map!("b", "a * b").map!(a => a[0]);

    assert(combine1[0, 0] == 1);
    assert(combine2[0, 0] == 1);
    static assert(is(typeof(combine2[0, 0]) == sizediff_t));
}
