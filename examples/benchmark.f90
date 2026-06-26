! Benchmark: call ehGreen Green function via shared library (libehgreen.so)
program main
  use iso_c_binding
  use omp_lib
  implicit none
  ! Interface to kernel_piz exported from libehgreen.so
  ! p: pulsating source
  ! i: infinite water depth
  ! z: zero speed
  interface
    subroutine kernel_piz(r, z, res) bind(C, name="kernel_piz")
      use iso_c_binding
      real(c_double), intent(in)  :: r, z
      real(c_double), intent(out) :: res(4)
    end subroutine
  end interface

  real(8)  :: r(10000), z(1000)
  real(8)  :: res(4), hh
  integer :: nr, nz, i, j, epoch
  real(8) :: start, finish

  nr = 10000
  nz = 1000

  r(1:nr) = [(i, i=0, nr-1)] / dble(nr)
  z(1:nz) = [(i, i=0, nz-1)] / dble(nz)

  r = r * 38
  z = z * 15

  print*, "[INFO] Calling kernel_piz via ISO_C_BINDING from libehgreen.so"

  ! Performance test (single thread)
  do epoch = 1, 3
    print "(A5,I1,A)", "--- Run ", epoch, " (single thread, 10M calls) ---"
    call cpu_time(start)
    do i = 1, nr
      hh = r(i)
      do j = 1, nz
        call kernel_piz(hh, z(j), res)
      end do
    end do
    call cpu_time(finish)
    print "(A,F8.3,A)", "    Elapsed: ", finish - start, " s"
    print*
  end do

  ! Performance test (OpenMP multi-thread)
  do epoch = 1, 3
    print "(A5,I1,A)", "--- Run ", epoch, " (OpenMP multi-thread, 10M calls) ---"
    start = omp_get_wtime()
    !$OMP PARALLEL DO PRIVATE(j, hh, res)
    do i = 1, nr
      hh = r(i)
      do j = 1, nz
        call kernel_piz(hh, z(j), res)
      end do
    end do
    !$OMP END PARALLEL DO
    finish = omp_get_wtime()
    print "(A,F8.3,A)", "    Elapsed: ", finish - start, " s"
    print*
  end do

end program main
