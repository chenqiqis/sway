//! A library for allocating memory inspired by [Rust's std::alloc](https://doc.rust-lang.org/std/alloc/index.html).
library;

/// Allocates zeroed memory on the heap.
///
/// In the FuelVM, the heap begins at `VM_MAX_RAM` and grows downward.
/// The heap pointer(`$hp`) always points to the first allocated byte.
///
/// Initially the heap will look like this:
/// ```
///                                                     ▾$hp
/// ... 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 |
///                                                     ▴VM_MAX_RAM
/// ```
/// After allocating with `let ptr = alloc::<u64>(1)`:
/// ```
///                             ▾$hp
/// ... 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 |
///                             ▴ptr                    ▴VM_MAX_RAM
/// ```
/// After writing with `sw(ptr, u64::max())`:
/// ```
///                             ▾$hp
/// ... 00 00 00 00 00 00 00 00 FF FF FF FF FF FF FF FF |
///                             ▴ptr                    ▴VM_MAX_RAM
/// ```
/// For more information, see the Fuel Spec for [VM Initialization](https://fuellabs.github.io/fuel-specs/master/vm#vm-initialization)
/// and the VM Instruction Set for [Memory Allocation](https://fuellabs.github.io/fuel-specs/master/vm/instruction_set.html#aloc-allocate-memory).
pub fn alloc<T>(count: u64) -> raw_ptr {
    raw_slice::alloc_t::<T>(count).ptr()
}

/// Reallocates the given area of memory.
pub fn realloc<T>(ptr: raw_ptr, count: u64, new_count: u64) -> raw_ptr {
    if new_count > count {
        let new_ptr = raw_slice::alloc_t::<T>(new_count).ptr();
        if count > 0 {
            ptr.copy_to_t::<T>(new_ptr, count);
        }
        new_ptr
    } else {
        ptr
    }
}
