use libc::{c_double as double, c_int as int};
use std::ffi::CStr;
use std::os::raw::c_char;

extern "C" {
    pub fn init_julia(argc: i32, argv: *const *const c_char);
    //pub fn callback_fn(x: *const double, y: *const double) -> int; 
    pub fn julia_cg(
        fptr: unsafe extern "C" fn(*mut f64, *mut f64) -> i32,
        x: *const f64,
        y: *const f64,
        len: u64
    ) -> i32;
    pub fn shutdown_julia(retcode: i32);
}

#[no_mangle]
pub unsafe extern "C" fn laplace(mut _y: *mut libc::c_double,
                                 mut _x: *mut libc::c_double) -> libc::c_int {
    let len: usize = 10;
    let c: f64 = 0.01;

    let y = std::slice::from_raw_parts_mut(_y, len);
    let x = std::slice::from_raw_parts_mut(_x, len);

    y[0] = x[0]-c*x[1];

    for i in 1..(len-1){
        y[i] = x[i] -c*(x[i-1]+x[i+1])
    }

    y[len-1] = x[len-1]-c*x[len-2];
    return 0 as libc::c_int;
}


fn main() {
    unsafe {
        init_julia(0, &vec![].as_ptr());
    }

    let b = [1.0; 10];
    let x = [0.0; 10];

    unsafe{
        let ret = julia_cg(laplace, x.as_ptr(), b.as_ptr(), 10);
    }

    unsafe {
        shutdown_julia(0);
    }

}
