module ehGreen
  implicit none
  real(8),parameter    ::  PI  = 3.1415926535897932d0
  real(8),parameter    ::  PI2 = 6.2831853071795865d0
contains
  INCLUDE 'kernel_piz_impl.inc'
  function quickExp(z) result(expz)
    implicit none
    real(8):: z,expz
    real(8):: tmp
    
    if(z<2)then
      expz = (193d0+(-87d0+(15d0-z)*z)*z)/(z*(z*(2.71828182845905d0*z+24.4645364561314d0)+106.012991309903d0)+192.998009820592d0)
    elseif(z<4)then
      expz = (435d0+(-159d0+(21d0-z)*z)*z)/(z*(z*(20.0855369231877d0*z+60.2566107695630d0)+301.283053847815d0)+421.796275386941d0)
    elseif(z<8)then
      tmp = z*0.5d0
      expz = ((435d0+(-159d0+(21d0-tmp)*tmp)*tmp)/(tmp*(tmp*(20.0855369231877d0*tmp+60.2566107695630d0)+301.283053847815d0)+421.796275386941d0))
      expz = expz*expz
    elseif(z<16)then
      tmp = z*0.25d0
      expz = ((435d0+(-159d0+(21d0-tmp)*tmp)*tmp)/(tmp*(tmp*(20.0855369231877d0*tmp+60.2566107695630d0)+301.283053847815d0)+421.796275386941d0))
      expz = expz*expz
      expz = expz*expz
    else
      expz = dexp(-z)
    endif
  endfunction
  function quickCos(x) result(res)
    real(8):: x,res
    real(8):: tmp
    tmp = x-PI2*floor(x/PI2)
    if(tmp<1.57079632679490d0)then
      res=(((78912d0*tmp-301900.019610058d0)*tmp-167167.224855731d0)*tmp+701689.202374655d0)/(((-8055.36045127715d0*tmp+50477.3603729861d0)*tmp-167563.819840501d0)*tmp+701733.756703196d0)
    elseif(tmp<3.1415926535898d0)then
      tmp = 3.1415926535898d0-tmp
      res=-(((78912d0*tmp-301900.019610058d0)*tmp-167167.224855731d0)*tmp+701689.202374655d0)/(((-8055.36045127715d0*tmp+50477.3603729861d0)*tmp-167563.819840501d0)*tmp+701733.756703196d0)
    elseif(tmp<4.71238898038469d0)then
      tmp =tmp-3.1415926535898d0
      res=-(((78912d0*tmp-301900.019610058d0)*tmp-167167.224855731d0)*tmp+701689.202374655d0)/(((-8055.36045127715d0*tmp+50477.3603729861d0)*tmp-167563.819840501d0)*tmp+701733.756703196d0)
    else
      tmp =6.28318530717959d0-tmp
      res=(((78912d0*tmp-301900.019610058d0)*tmp-167167.224855731d0)*tmp+701689.202374655d0)/(((-8055.36045127715d0*tmp+50477.3603729861d0)*tmp-167563.819840501d0)*tmp+701733.756703196d0)
    endif
  endfunction
  subroutine besselJ(x,j0,j1)
    real(8):: x,res,j0,j1
    real(8):: tmp,f0,theta0
    tmp = x*x/9.0d0
    if(x<3.d0)then
      j0 = 0.999999999d0+(-2.249999879d0+(1.265623060d0+(-0.316394552d0+(0.044460948d0+(-0.003954479d0+0.000212950d0*tmp)*tmp)*tmp)*tmp)*tmp)*tmp
      j1 = (0.5d0+(-0.562499992d0+(0.210937377d0+(-0.039550040d0+(0.004447331d0+(-0.000330547d0+0.000015525d0*tmp)*tmp)*tmp)*tmp)*tmp)*tmp)*x
    else
      tmp = 1/tmp
      f0 = 0.79788454d0+(-0.00553897d0+(0.00099336d0+(-0.00044346d0+(0.00020445d0-0.00004959d0*tmp)*tmp)*tmp)*tmp)*tmp
      theta0 = x-0.785398163397448d0+(-0.04166592d0+(0.00239399d0+(-0.00073984d0+(0.00031099d0-0.00007605d0*tmp)*tmp)*tmp)*tmp)*3.d0/x
      j0 = f0*quickCos(theta0)/dsqrt(x)
      f0 = 0.79788459d0+(0.01662008d0+(-0.00187002d0+(0.00068519d0+(-0.00029440d0+0.00006952d0*tmp)*tmp)*tmp)*tmp)*tmp
      theta0 = x-2.35619449019235d0+(0.12499895d0+(-0.00605240d0+(0.00135825d0+(-0.00049616d0+0.00011531d0*tmp)*tmp)*tmp)*tmp)*3.d0/x
      j1 = f0*quickCos(theta0)/dsqrt(x)
    endif
  endsubroutine
  function Y0H0fuse(x) result(res)
    implicit none
    real(8)  ::  x,tmp,res,inv_x,sqrt_x,f0,theta0

    if(x <= 3.0d0) then
      tmp  =  x*x/9.0d0
      res  =  1.909859164d0+(-1.909855001d0+(0.687514637d0+(-0.126164557d0+(0.013828813d0-0.000876918d0*tmp)*tmp)*tmp)*tmp)*tmp
      res  =  res*(x/3.0d0)+Bessel_Y0(x)
    else
      inv_x = 1.0d0/x
      tmp   = 9.0d0*inv_x*inv_x
      sqrt_x = dsqrt(x)
      f0 = 0.79788454d0+(-0.00553897d0+(0.00099336d0+(-0.00044346d0+(0.00020445d0-0.00004959d0*tmp)*tmp)*tmp)*tmp)*tmp
      theta0 = x-0.785398163397448d0+(-0.04166592d0+(0.00239399d0+(-0.00073984d0+(0.00031099d0-0.00007605d0*tmp)*tmp)*tmp)*tmp)*3.0d0*inv_x
      res = 2.0d0*f0*dsin(theta0)/sqrt_x+0.636619772367581d0*(0.99999906d0+(4.77228920d0+(3.85542044d0+0.32303607d0*tmp)*tmp)*tmp)/(x*(1.0d0+(4.88331068d0+(4.28957333d0+0.52120508d0*tmp)*tmp)*tmp))
    endif
  endfunction
  function Y1H1fuse(x) result(res)
    implicit none
    real(8)  ::  x,tmp,res,inv_x,sqrt_x,f0,theta0

    if(x <= 3.0d0) then
      tmp  =  x*x/9.0d0
      res  =  (1.909859286d0+(-1.145914713d0+(0.294656958d0+(-0.042070508d0+(0.003785727d0-0.000207183d0*tmp)*tmp)*tmp)*tmp)*tmp)*tmp+Bessel_Y1(x)-0.636619772367581d0
    else
      inv_x = 1.0d0/x
      tmp   = 9.0d0*inv_x*inv_x
      sqrt_x = dsqrt(x)
      f0 = 0.79788459d0+(0.01662008d0+(-0.00187002d0+(0.00068519d0+(-0.00029440d0+0.00006952d0*tmp)*tmp)*tmp)*tmp)*tmp
      theta0 = x-2.35619449019235d0+(0.12499895d0+(-0.00605240d0+(0.00135825d0+(-0.00049616d0+0.00011531d0*tmp)*tmp)*tmp)*tmp)*3.0d0*inv_x
      res = 2.0d0*f0*dsin(theta0)/sqrt_x+0.636619772367581d0*(1.00000004d0+(3.92205313d0+(2.64893033d0+0.27450895d0*tmp)*tmp)*tmp)/(1.0d0+(3.81095112d0+(2.26216956d0+0.10885141d0*tmp)*tmp)*tmp)-0.636619772367581d0
    endif
  endfunction
end module
