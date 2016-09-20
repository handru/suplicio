c234567                        INVISIDos2.F        (con UU = Uo < Uinf = U)  
c      rev.23/03/99
c      rev.07/06/99  invis.f
c      rev.25/02/00  invis2.f
c      rev.02/03/01  invisidos.f
c      rev.08/03/05  invisidos.f
c 
c integracion por Simpson de la ley de Biot-Savart                  
c
c.......................................................................
c>
      implicit real*8 (a-h,o-z)
c
      parameter (maxir=51,maxio=51,maxip=11,maxnk=2001,
     &          mxir=maxir-1,mxio=maxio-1,mxip=maxip-1,
     &          maxro=maxir*maxio,mxro=mxir*mxio,mxnk=maxnk-1)
c
      common r(maxir),o(maxio),chord(maxir),yarc(maxir,maxio)
      common px(maxro),py(maxro),pz(maxro)
      common xbf(maxir),ybf(maxir),zbf(maxir),rbf(maxir)
      common xe(maxir,maxnk),ye(maxir,maxnk),ze(maxir,maxnk),
     &       re(maxir,maxnk),fi(maxir,maxnk),fifa(mxro,5),fipri(mxro,5)
c     
      common p1x(mxro),p1y(mxro),p1z(mxro),      
     &       p2x(mxro),p2y(mxro),p2z(mxro),
     &       p3x(mxro),p3y(mxro),p3z(mxro),
     &       p4x(mxro),p4y(mxro),p4z(mxro),
     &       pax(mxro),pay(mxro),paz(mxro),
     &       pbx(mxro),pby(mxro),pbz(mxro)
c
      common pcx(mxro,maxip),pcy(mxro,maxip),pcz(mxro,maxip),
     &       area(mxro),ss1(mxro,maxip),ss2(mxro,maxip),
     &       vnx(mxro),vny(mxro),vnz(mxro),Vinf(mxro)
c
      common gamma(mxro),circ(maxro),carga(mxro),theta(1)  
      common ciex(mxro,maxir),ciey(mxro,maxir),ciez(mxro,maxir),
     &       cix1tmp(mxro*mxro),ciy1tmp(mxro*mxro),ciz1tmp(mxro*mxro),
     &       cix2tmp(mxro*mxro),ciy2tmp(mxro*mxro),ciz2tmp(mxro*mxro)
!    Variables cix1tmp, ciy1tmp, ciz1tmp, para reemplazar a los archivos
!    con el mismo nombre. Lo mismo para cix2tmp, ciy2tmp, ciz2tmp.
      common vix(mxro,maxip),viy(mxro,maxip),viz(mxro,maxip),
     &       vi(mxro,maxip),vtgx(mxro,maxip),vtgy(mxro,maxip),
     &       urx(mxro,maxip),ury(mxro,maxip),urz(mxro,maxip)     
      common urex(mxro),urey(mxro),urez(mxro),
     &       urix(mxro),uriy(mxro),uriz(mxro)
c
      common U,UU,omega,c0,a,rh,rt,oi,of,pf,ch,ct,zlim,factor1,factor2
      common pi,beta,cero,signo,redvel,coefa,hc,dfi,alfac,c1,c2,distan
      common indice,index0,index1,index2,index3,index4,index5,index6,      
     &       index7,index8,index9,index10,index11,index12,alfac0      
      common npan,nodos,ncapa,npal,npaso,nr,no,np,nk,kult,inic,in1,in2, 
     &       in3,nsubr,nsld2
c
c     Variables para llevar los archivos de texto en memoria, como 
c     internal files de Fortran
      character integ1(maxro)*150,integ2(maxro)*150,gamastr(maxro)*70,
     &          circostr(maxro)*70,salida2out(102)*95
c     Variable para internal file del archivo global subr.out
c     el cual lleva los mismos datos que la salida estandar
      character subrout(500)*60
c                      
      common integ1,integ2,gamastr,circostr,subrout,salida2out
c
      character outstd(50)*100,marca*60
      integer tam
!  OUTSTD es un array de caracteres para llevar la salida estandar de las 
!  subrutinas, en lugar de hacer write(6). Se difiere su escritura en 
!  pantalla hasta volver al programa Main. 
!  TAM lleva la cantidad de posiciones utilizadas en OUTSTD
!  Ambas variables van por parametro en el nombre de la subrutina.
c<
c.......................................................................
c
c
      open(unit=5, file='entvis2f.in')
      open(unit=50,file='salida2.out')
c     open(unit=7, file='xyz.plt')
      open(unit=8, file='palest.plt')
      open(unit=52,file='palas.plt')
      open(unit=10,file='panel.plt')
      open(unit=11,file='panel.txt')
      open(unit=12,file='pres.plt')
      open(unit=13,file='velxyz.txt')
      open(unit=14,file='estel1.txt')
      open(unit=15,file='subr.out')
      open(unit=16,file='gama.txt')
      open(unit=17,file='estel2.txt')
      open(unit=18,file='estel3.txt')
      open(unit=19,file='coord.txt')
      open(unit=20,file='vn.txt')
      open(unit=21,file='velindad.txt')
      open(unit=22,file='velpotad.txt')
      open(unit=53,file='velcapae.txt')
      open(unit=54,file='velcapai.txt')
      open(unit=55,file='veltotal.txt')
      open(unit=56,file='vel01ext.txt')
      open(unit=57,file='vel01int.txt')
      open(unit=58,file='vel02ext.txt')
      open(unit=59,file='vel02int.txt')
      open(unit=60,file='vel02pvn.txt')
      open(unit=23,file='velindad.plt')
      open(unit=24,file='velresad.plt')
      open(unit=25,file='cp075c.txt')
      open(unit=61,file='cpei.txt')
      open(unit=62,file='cpei.plt')
      open(unit=26,file='arco.txt')
      open(unit=27,file='coefp.txt')
      open(unit=28,file='circo.txt')
      open(unit=33,file='integ1.txt')
      open(unit=34,file='vix.txt')
      open(unit=35,file='viy.txt')
      open(unit=36,file='viz.txt')
      open(unit=37,file='cp1.txt')
      open(unit=38,file='cp2.txt')
      open(unit=39,file='integ2.txt')
      open(unit=48,file='fzas.txt')
      open(unit=49,file='fuerza.plt')
      open(unit=99,file='vector.plt')
      open(unit=51,file='alfa.txt')  
c      
c      open(unit=40,file='coefg.tmp',status='unknown',access='direct',
c     &     form='unformatted')
c      open(unit=41,file='cindg.tmp',status='unknown',access='direct',
c     &     form='unformatted')
c      open(unit=42,file='cix1.tmp',status='unknown',access='direct',
c     &     form='unformatted')
c      open(unit=43,file='ciy1.tmp',status='unknown',access='direct',
c     &     form='unformatted')
c      open(unit=44,file='ciz1.tmp',status='unknown',access='direct',
c     &     form='unformatted')
c      open(unit=45,file='cix2.tmp',status='unknown',access='direct',
c     &     form='unformatted')
c      open(unit=46,file='ciy2.tmp',status='unknown',access='direct',
c     &     form='unformatted')
c      open(unit=47,file='ciz2.tmp',status='unknown',access='direct',
c     &     form='unformatted')
c      
!      open(unit=40,file='coefg.tmp',status='unknown',
!     &     form='unformatted')
!      open(unit=41,file='cindg.tmp',status='unknown',
!     &     form='unformatted')
!      open(unit=42,file='cix1.tmp',status='unknown',
!     &     form='unformatted')
!      open(unit=43,file='ciy1.tmp',status='unknown',
!     &     form='unformatted')
!      open(unit=44,file='ciz1.tmp',status='unknown',
!     &     form='unformatted')
!      open(unit=45,file='cix2.tmp',status='unknown',
!     &     form='unformatted')
!      open(unit=46,file='ciy2.tmp',status='unknown',
!     &     form='unformatted')
!      open(unit=47,file='ciz2.tmp',status='unknown',
!     &     form='unformatted')
c
      nsld2=1
      nsubr=1
      write(subrout(nsubr),1)
      nsubr=nsubr+1
!      write(15,1)
      write(6,1)          
      print*,""
      call input  
c
      write(subrout(nsubr),2)
      nsubr=nsubr+1
!      write(15,2)
      write(6,2)
      print*,""
      call coord3d
      close(26)        
c
      write(subrout(nsubr),3)
      nsubr=nsubr+1
!      write(15,3)
      write(6,3)                                                        
      print*,""
      call palas
c                                                
c     PRIMERA PARTE                                                        
c                                                
c     ncapa = 1 (pala)		 Indice = 1
c
c     ptos de colocacion a 3c/4
c                                
      indice = 1
      ncapa  = 1
c
      write(subrout(nsubr),21)
      nsubr=nsubr+1
!      write(15,21)
c
      write(subrout(nsubr),4)indice,ncapa
      nsubr=nsubr+1
!      write(15,4)indice,ncapa
      write(6,4) indice,ncapa
      print*,""
      call panel(outstd,tam)
      do 705 ind1=1,tam-1
       print*,outstd(ind1)
  705 continue
c
      if(index5.eq.0) goto 50
c
      write(subrout(nsubr),5)indice,ncapa
      nsubr=nsubr+1
!      write(15,5)indice,ncapa
      write(6,5) indice,ncapa
      print*,""
      !print*,"holamundo"
      call anillo(outstd,tam)
      do 706 ind1=1,tam-1
       print*,outstd(ind1)
  706 continue
c
   50 continue
c
      write(subrout(nsubr),7)indice,ncapa
      nsubr=nsubr+1
!      write(15,7)indice,ncapa
      write(6,7) indice,ncapa
      print*,""
      call geomest(outstd,tam)
      do 707 ind1=1,tam-1
       print*,outstd(ind1)
  707 continue
c                      
      if(index5.eq.0) goto 100
c
      write(subrout(nsubr),8)indice,ncapa
      nsubr=nsubr+1
!      write(15,8)indice,ncapa
      write(6,8) indice,ncapa
      print*,""
      call estela(outstd,tam)
      do 770 in3=1,kult+1
       write(33,'(a137)')integ1(in3)  !Escribe el archivo integ1.txt de estela
       write(39,'(a137)')integ2(in3)  !Escribe el archivo integ2.txt de estela
       ! formato a137 debido a la cantidad de columnas necesarias para los datos
  770 continue
      do 708 ind1=1,tam-1
       print*,outstd(ind1)
  708 continue
      close(33)
      close(39)
c
      write(subrout(nsubr),9)indice,ncapa
      nsubr=nsubr+1
!      write(15,9)indice,ncapa
      write(6,9) indice,ncapa
      print*,""
      call coefin    
c
      write(subrout(nsubr),10)indice,ncapa
      nsubr=nsubr+1
!      write(15,10)indice,ncapa
      write(6,10) indice,ncapa
      print*,""
      call circulac(outstd,tam)
      do 709 ind1=1,tam-1
       print*,outstd(ind1)
  709 continue
c
      write(subrout(nsubr),11)indice,ncapa
      nsubr=nsubr+1
!      write(15,11)indice,ncapa
      write(6,11) indice,ncapa
      print*,""
      call veloc
c
      write(subrout(nsubr),12)indice,ncapa
      nsubr=nsubr+1
!      write(15,12)indice,ncapa
      write(6,12) indice,ncapa
      print*,""
      call ploteo1
c                 
      write(subrout(nsubr),13)indice,ncapa
      nsubr=nsubr+1
!      write(15,13)indice,ncapa
      write(6,13) indice,ncapa
      print*,""
      call ploteo2
c                 
      write(subrout(nsubr),16)indice,ncapa
      nsubr=nsubr+1
!      write(15,16)indice,ncapa
      write(6,16) indice,ncapa
      print*,""
      call presion1
c                                              
c-----
c
      if(index4.ne.0)  goto 69    
      if(index4.eq.0)  goto 66		  !no calcula @ c/4 y P's (HILO)
   69 continue       
c
c     SEGUNDA PARTE
c									  
c     ncapa = 10 						  Indice = 2
c
c     ptos de colocacion a c/4  (index4 =/= 0), en HILO LIGADO o
c     ptos de calculo           (index4 =/= 0), en P1,P2,P3 o P4            
c
c    P1 si index11=1        c/4 si index11 = 0         P2 si index11=2  
c    P3 si index11=3        c/4 si index11 = 0         P4 si index11=4  
c
c    Solamente se calculan las cargas por teor de Kutta-J si index11=0
c                                
      indice = 2 
      ncapa  = 10
c
	write(subrout(nsubr),21)
      nsubr=nsubr+1
!      write(15,21)
c
      write(subrout(nsubr),14)indice,ncapa
      nsubr=nsubr+1
!      write(15,14)indice,ncapa
      write(6,14) indice,ncapa
      print*,""
      call hilo
c
      write(subrout(nsubr),5)indice,ncapa
      nsubr=nsubr+1
!      write(15,5)indice,ncapa
      write(6,5) indice,ncapa
      print*,""
      call anillo(outstd,tam)
      do 710 ind1=1,tam-1
       print*,outstd(ind1)
  710 continue
c
      write(subrout(nsubr),8)indice,ncapa
      nsubr=nsubr+1
!      write(15,8)indice,ncapa
      write(6,8) indice,ncapa
      print*,""
      call estela(outstd,tam)
      do 711 ind1=1,tam-1
       print*,outstd(ind1)
  711 continue
c
      write(subrout(nsubr),9)indice,ncapa
      nsubr=nsubr+1
!      write(15,9)indice,ncapa
      write(6,9) indice,ncapa
      print*,""
      call coefin    
c
      write(subrout(nsubr),11)indice,ncapa
      nsubr=nsubr+1
!      write(15,11)indice,ncapa
      write(6,11) indice,ncapa
      print*,""
      call veloc
c
      write(subrout(nsubr),12)indice,ncapa
      nsubr=nsubr+1
!      write(15,12)indice,ncapa
      write(6,12) indice,ncapa
      print*,""
      call ploteo1
c                 
      write(subrout(nsubr),13)indice,ncapa
      nsubr=nsubr+1
!      write(15,13)indice,ncapa
      write(6,13) indice,ncapa
      print*,""
      call ploteo2
c
      if(index11.eq.0) write(subrout(nsubr),19)indice,ncapa
      if(index11.eq.0) nsubr=nsubr+1
!      write(15,19)indice,ncapa
      if(index11.eq.0) write(6,19) indice,ncapa
      if(index11.eq.0) print*,""
      if(index11.eq.0) call cargas  
c
c      write(subrout(nsubr),16)indice,ncapa
!      write(15,16)indice,ncapa
c      write(6,16) indice,ncapa
c      call presion
c     
c-----
c
   66 continue      
      if(index0.eq.0) goto 101    
c 
c     TERCERA PARTE
c
c	ncapa = 2,3,4,5,6,7,8 y 9			Indice = 3
c                                    
c     condiciones de contorno:
c     ptos sobre el contorno anterior     (ncapa = 2)
c     ptos sobre el contorno superior     (ncapa = 3)
c     ptos sobre el contorno lateral int. (ncapa = 4)
c     ptos sobre el contorno lateral ext. (ncapa = 5)
c     y en c/2 del panel (si inic = 1)
c
      indice = 3  
      if(np.eq.0) goto 100
c                                   
      if(index3.ne.0) inic=1
      if(index3.eq.0) inic=2
c                           
      write(subrout(nsubr),96)inic,np+1
      nsubr=nsubr+1
!      write(15,96)inic,np+1
      write(6,96) inic,np+1
      print*,""
! BORRADOS CARACTERES  ,/  DEL FINAL DE FORMAT
   96 format(17x,2(5x,i2))   
c
c
c      do 99 ncapa= inic,np+1
c
c      if(inic.eq.2) goto 98
c      write(subrout(nsubr),4)indice,ncapa
!      write(15,4)indice,ncapa
c      write(6,4) indice,ncapa
c      call panel 
c      goto 97         
c   98 continue   
c      
c      if(ncapa.eq.2)write(subrout(nsubr),15)indice,ncapa
!      write(15,15)indice,ncapa
c      if(ncapa.eq.2)write(6,15) indice,ncapa
c      if(ncapa.eq.2)call puntos2
c      
c      if(ncapa.eq.3)write(subrout(nsubr),15)indice,ncapa
!      write(15,15)indice,ncapa
c      if(ncapa.eq.3)write(6,15) indice,ncapa
c      if(ncapa.eq.3)call puntos3
c      
c      if(ncapa.eq.4)write(subrout(nsubr),15)indice,ncapa
!      write(15,15)indice,ncapa
c      if(ncapa.eq.4)write(6,15) indice,ncapa
c      if(ncapa.eq.4)call puntos45
c      
c      if(ncapa.eq.5)write(subrout(nsubr),15)indice,ncapa
!      write(15,15)indice,ncapa
c      if(ncapa.eq.5)write(6,15) indice,ncapa
c      if(ncapa.eq.5)call puntos45
c   97 continue   
c
      do 112 ncapa = 2,9
c
	write(subrout(nsubr),21)
      nsubr=nsubr+1
!      write(15,21)
c
      write(subrout(nsubr),15)indice,ncapa
      nsubr=nsubr+1
!      write(15,15)indice,ncapa
      write(6,15) indice,ncapa
      print*,""
      call puntos1 
c
      write(subrout(nsubr),5)indice,ncapa
      nsubr=nsubr+1
!      write(15,5)indice,ncapa
      write(6,5) indice,ncapa
      print*,""
      call anillo(outstd,tam)
      do 712 ind1=1,tam-1
       print*,outstd(ind1)
  712 continue
c
      write(subrout(nsubr),8)indice,ncapa
      nsubr=nsubr+1
!      write(15,8)indice,ncapa
      write(6,8) indice,ncapa
      print*,""
      call estela(outstd,tam)
      do 713 ind1=1,tam-1
       print*,outstd(ind1)
  713 continue
c
      write(subrout(nsubr),9)indice,ncapa
      nsubr=nsubr+1
!      write(15,9)indice,ncapa
      write(6,9) indice,ncapa
      print*,""
      call coefin    
c
      write(subrout(nsubr),11)indice,ncapa
      nsubr=nsubr+1
!      write(15,11)indice,ncapa
      write(6,11) indice,ncapa
      print*,""
      call veloc
c                            
c  99 continue   
  112 continue
c
	write(subrout(nsubr),21)
      nsubr=nsubr+1
!      write(15,21)
c
      write(subrout(nsubr),20)indice,ncapa
      nsubr=nsubr+1
!      write(15,20)indice,ncapa
      write(6,20) indice,ncapa
      print*,""
      call velsuper 
c
      write(subrout(nsubr),12)indice,ncapa
      nsubr=nsubr+1
!      write(15,12)indice,ncapa
      write(6,12) indice,ncapa
      print*,""
c      call ploteo1 
c                 
      write(subrout(nsubr),13)indice,ncapa
      nsubr=nsubr+1
!      write(15,13)indice,ncapa
      write(6,13) indice,ncapa
      print*,""
c      call ploteo2
c									ncapa = 10: EXTRADOS
      write(subrout(nsubr),16)indice,ncapa
      nsubr=nsubr+1
!      write(15,16)indice,ncapa
      write(6,16) indice,ncapa
      print*,""
      call presion2  				   
c									ncapa = 11: INTRADOS
      ncapa = ncapa+1
      write(subrout(nsubr),16)indice,ncapa
      nsubr=nsubr+1
!      write(15,16)indice,ncapa
      write(6,16) indice,ncapa
      print*,""
      call presion2  				
c
      write(subrout(nsubr),21)
      nsubr=nsubr+1
!      write(15,21)
c     
c-----
c            
  101 continue                    
  100 continue
c
      do 703 nultimo=1,nsld2-1
        write(50,'(a)') trim(salida2out(nultimo))
  703 continue
c
      marca="M"
      do 704 nultimo=1,nsubr-1
      if(subrout(nultimo).ne.marca) then
        write(15,'(a)') trim(subrout(nultimo))
        write(15,'(a)')""
      else
        write(15,'(a)')""
      endif
  704 continue
c
      close(5)
      close(50)
c     close(7)
      close(8)
      close(10)
      close(11)
      close(12)
      close(13)
      close(14)
      close(15)
      close(16)
      close(17)
      close(18)
      close(19)
      close(20)
      close(21)
      close(22)
      close(23)
      close(24)
      close(25)
!      close(26)        
      close(27)                     
      close(28)
      !close(33)
      close(34)
      close(35)
      close(36)
      close(37)
      close(38)
!      close(39)
!      close(40)
!      close(41)
!      close(42)
!      close(43)
!      close(44)
!      close(45)
!      close(46)
!      close(47)
      close(48)
      close(49)
      close(51)
      close(52)
      close(53)
      close(54)
      close(55)
      close(56)
      close(57)
      close(58)
      close(59)
      close(60)
      close(61)
      close(62)
      close(99)
cccc
c
      if(index5.ne.0) write(6,17) nr,no      
      if(index5.ne.0) print*,""
      if(index5.ne.0) call circo(nr,no,circostr,maxro)
c
      if(index5.ne.0) write(6,18) nr,no      
      if(index5.ne.0) print*,""
      if(index5.ne.0) call gammas(nr,no,gamastr,maxro)
c
c ---- SE QUITA AL FINAL DE CADA LINEA FORMAT LOS CARACTERES
c ---- SIGUIENTES  ,/ 
c ---- PARA EVITAR ERRORES EN EL INTERNAL FILE SUBROUT
    1 format(2x,'input       (1)') 
    2 format(2x,'coord3d     (2)') 
    3 format(2x,'palas       (3)') 
    4 format(2x,'panel       (4)',2(5x,i2)) 
    5 format(2x,'anillo      (5)',2(5x,i2)) 
    7 format(2x,'geomest     (7)',2(5x,i2)) 
    8 format(2x,'estela      (8)',2(5x,i2))        
    9 format(2x,'coefin      (9)',2(5x,i2))        
   10 format(2x,'circulac   (10)',2(5x,i2))                           
   11 format(2x,'veloc      (11)',2(5x,i2))                           
   12 format(2x,'ploteo1    (12)',2(5x,i2))                           
   13 format(2x,'ploteo2    (13)',2(5x,i2)) 
   14 format(2x,'hilo       (14)',2(5x,i2)) 
   15 format(2x,'puntos     (15)',2(5x,i2)) 
   16 format(2x,'presion    (16)',2(5x,i2)) 
   17 format(2x,'circo      (17)',2(5x,i2))     
   18 format(2x,'gammas     (18)',2(5x,i2)) 
   19 format(2x,'cargas     (19)',2(5x,i2)) 
   20 format(2x,'velsuper   (20)',2(5x,i2)) 
   21 format(1x,50('-'))
c
      stop
      end
c
c-----------------------------------------------------------------------
c
      subroutine input
c
c.......................................................................
c>
      implicit real*8 (a-h,o-z)
c
      parameter (maxir=51,maxio=51,maxip=11,maxnk=2001,
     &          mxir=maxir-1,mxio=maxio-1,mxip=maxip-1,
     &          maxro=maxir*maxio,mxro=mxir*mxio,mxnk=maxnk-1)
c
      common r(maxir),o(maxio),chord(maxir),yarc(maxir,maxio)
      common px(maxro),py(maxro),pz(maxro)
      common xbf(maxir),ybf(maxir),zbf(maxir),rbf(maxir)
      common xe(maxir,maxnk),ye(maxir,maxnk),ze(maxir,maxnk),
     &       re(maxir,maxnk),fi(maxir,maxnk),fifa(mxro,5),fipri(mxro,5)
c     
      common p1x(mxro),p1y(mxro),p1z(mxro),      
     &       p2x(mxro),p2y(mxro),p2z(mxro),
     &       p3x(mxro),p3y(mxro),p3z(mxro),
     &       p4x(mxro),p4y(mxro),p4z(mxro),
     &       pax(mxro),pay(mxro),paz(mxro),
     &       pbx(mxro),pby(mxro),pbz(mxro)
c
      common pcx(mxro,maxip),pcy(mxro,maxip),pcz(mxro,maxip),
     &       area(mxro),ss1(mxro,maxip),ss2(mxro,maxip),
     &       vnx(mxro),vny(mxro),vnz(mxro),Vinf(mxro)
c
      common gamma(mxro),circ(maxro),carga(mxro),theta(1)  
      common ciex(mxro,maxir),ciey(mxro,maxir),ciez(mxro,maxir),
     &       cix1tmp(mxro*mxro),ciy1tmp(mxro*mxro),ciz1tmp(mxro*mxro),
     &       cix2tmp(mxro*mxro),ciy2tmp(mxro*mxro),ciz2tmp(mxro*mxro)
      common vix(mxro,maxip),viy(mxro,maxip),viz(mxro,maxip),
     &       vi(mxro,maxip),vtgx(mxro,maxip),vtgy(mxro,maxip),
     &       urx(mxro,maxip),ury(mxro,maxip),urz(mxro,maxip)     
      common urex(mxro),urey(mxro),urez(mxro),
     &       urix(mxro),uriy(mxro),uriz(mxro)
c
      common U,UU,omega,c0,a,rh,rt,oi,of,pf,ch,ct,zlim,factor1,factor2
      common pi,beta,cero,signo,redvel,coefa,hc,dfi,alfac,c1,c2,distan
      common indice,index0,index1,index2,index3,index4,index5,index6,      
     &       index7,index8,index9,index10,index11,index12,alfac0      
      common npan,nodos,ncapa,npal,npaso,nr,no,np,nk,kult,inic,in1,in2, 
     &       in3,nsubr,nsld2
c
      character integ1(maxro)*150,integ2(maxro)*150,gamastr(maxro)*70,
     &          circostr(maxro)*70,salida2out(102)*95
c     Variable para internal file del archivo global subr.out
c     el cual lleva los mismos datos que la salida standar
      character subrout(500)*60
c                      
                      
      common integ1,integ2,gamastr,circostr,subrout,salida2out
c
c<
c.......................................................................
c
      read(5,1) U
      read(5,1) omega
      read(5,1) redvel 
      read(5,1) coefa
      read(5,1) ch
      read(5,1) ct
      read(5,1) rh
      read(5,1) rt
      read(5,1) oi
      read(5,1) of
      read(5,1) pf
      read(5,1) beta   
      read(5,1) signo
      read(5,3) nk 
      if(nk.gt.mxnk)  nk=mxnk  
                      kult=nk+1
      read(5,2) npal
      if(npal.ne.1) npal=1
      read(5,2) nr
      read(5,2) no
      read(5,2) np   
      read(5,2) npaso
      if(nr.ge.maxir) nr=maxir-1
      if(no.ge.maxio) no=maxio-1
      if(np.ge.maxip) np=maxip-1
      if(np.lt.0)     np=0  
      if(npaso.le.0)  npaso=1  
      read(5,2) index0
      read(5,2) index1
      read(5,2) index2
      read(5,2) index3
      read(5,2) index4
      read(5,2) index5
      read(5,2) index6
      read(5,2) index7
      read(5,2) index8
      read(5,2) index9
      read(5,2) index10
      read(5,2) index11
      read(5,2) index12
      read(5,1) alfac
      read(5,1) alfac0
      read(5,1) factor1
      read(5,1) factor2
      read(5,1) zlim  
      read(5,1) C1  
      read(5,1) Cte2
      if(index2.lt.0) read(5,1) hc 
      if(index2.lt.0.and.hc.eq.0.) index2=1 
c                    
      if(rh.eq.0.) rh=rt/100.
      signo=signo/dabs(signo)
      if(index1.ne.0) coefa=1.             
c                      
c    index0 = 0, calculo de distribucion de gamma, solamente. 
c    index1 = 0, a = U/w   =/=   c0 = UU/w
c
    1 format(f12.5)
    2 format(i3)
    3 format(i4)
c
	cmedia = (ch+ct)/2.d0
	distan = (ch+ct)/no
c
c    calculo de constantes
c    
      cero = 0.d0
       uno = 1.d0
        pi = 4.d0*datan(uno)
c
      alfac  = alfac*pi/180.d0      
      alfac0 = alfac0*pi/180.d0      
      if(beta.le.uno)beta = 1.01d0
c
c    npan:  numero total de paneles sobre la pala
c    nodos: numero total de nodos sobre la pala        
c
      npan = nr*no
      nodos=(nr+1)*(no+1)
c                       
c     tsr = W.R/U          a = U/W             
c     
c     Uo < U              c0 = Uo/W
c
      UU = U*(1.-redvel)
c
c     C2~ = cte2*(nu/Uo)^0.5
c      
      radc2 = 0.000015d0/UU
      C2 = cte2*dsqrt(radc2)
c      
      c0 = UU/omega
      if(index1.lt.0) a=U/omega
      if(index1.gt.0) a=UU/omega 
      if(index1.eq.0) a=coefa*UU/omega
      tsr  = rt*omega/U  
      tsr0 = rt*omega/UU 
c                    
      write(salida2out(nsld2),'(a1)') "" 
      write(salida2out(nsld2+1),9) redvel,coefa
      write(salida2out(nsld2+2),'(a1)') "" 
      write(salida2out(nsld2+3),91) alfac*180./pi,alfac0*180./pi           
      write(salida2out(nsld2+4),'(a1)') "" 
      nsld2=nsld2+5
    9 format(2x,'coef.red.vel.@ disco =',f6.3,9x,'coefa % =',f6.3,2x)
   91 format(2x,'alfa c =',f8.4,' grados',14x,'alfa0 c =',f8.4,
     &                               ' grados')  
!      write(50,9) redvel,coefa,alfac*180./pi,alfac0*180./pi           
!    9 format(2x,/,2x,'coef.red.vel.@ disco =',f6.3,9x,'coefa % =',f6.3,
!     &      2x,//,2x,'alfa c =',f8.4,' grados',14x,'alfa0 c =',f8.4,
!     &                               ' grados',/)  
c      
      write(salida2out(nsld2),4) U,UU,omega,U/omega
      write(salida2out(nsld2+1),'(a1)') "" 
      write(salida2out(nsld2+2),41) a,tsr,tsr0,c0
      write(salida2out(nsld2+3),'(a1)') "" 
      nsld2=nsld2+4
    4 format(2x,'U =',f9.4,' m/s',5x,'Uo =',f9.4,' m/s',
     &       5x,'W =',f9.4,' 1/s',13x,'U/W = ',f9.6,' m')
   41 format(2x,'a =',f11.6,7x,'tsr = WR/U =',f7.3,
     &       3x,'tsr0 = WR/Uo =',f7.3,3x,'C = Uo/W = ',f9.6,' m')
!      write(50,4) U,UU,omega,U/omega,a,tsr,tsr0,c0
!    4 format(2x,'U =',f9.4,' m/s',5x,'Uo =',f9.4,' m/s',
!     &       5x,'W =',f9.4,' 1/s',13x,'U/W = ',f9.6,' m',//,
!     &       2x,'a =',f11.6,7x,'tsr = WR/U =',f7.3,
!     &       3x,'tsr0 = WR/Uo =',f7.3,3x,'C = Uo/W = ',f9.6,' m',/)
c
      if(index2.eq.0) then
        write(salida2out(nsld2),5) rh
        write(salida2out(nsld2+1),51)rt
        write(salida2out(nsld2+2),52)oi
        write(salida2out(nsld2+3),53)of
        write(salida2out(nsld2+4),54)pf
        write(salida2out(nsld2+5),'(a1)') "" 
        write(salida2out(nsld2+6),55)npal
        write(salida2out(nsld2+7),'(a1)') "" 
        nsld2=nsld2+8
      endif
    5 format(2x,'rh [m]   =',f12.6)
   51 format(2x,'rt [m]   =',f12.6)
   52 format(2x,'Oi [rad] =',f12.6)
   53 format(2x,'Of [rad] =',f12.6)
   54 format(2x,'pf [m]   =',f12.6)
   55 format(2x,'numero de palas =',i3)   
!      if(index2.eq.0) write(50,5) rh,rt,oi,of,pf,npal
!    5 format(2x,'rh [m]   =',f12.6,/,
!     &       2x,'rt [m]   =',f12.6,/,
!     &       2x,'Oi [rad] =',f12.6,/,
!     &       2x,'Of [rad] =',f12.6,/,
!     &       2x,'pf [m]   =',f12.6,//,
!     &       2x,'numero de palas =',i3,/)   
c     
	if(index2.gt.0) hc = cero
c
      if(index2.ne.0) then
      write(salida2out(nsld2),8) rh
      write(salida2out(nsld2+1),81)rt
      write(salida2out(nsld2+2),82)ch
      write(salida2out(nsld2+3),83)ct
      write(salida2out(nsld2+4),84)pf
      write(salida2out(nsld2+5),'(a1)') "" 
      write(salida2out(nsld2+6),85)hc
      write(salida2out(nsld2+7),'(a1)') "" 
      write(salida2out(nsld2+8),86)npal
      write(salida2out(nsld2+9),'(a1)') "" 
      nsld2=nsld2+10
      endif
    8 format(2x,'rh [m]  =',f12.6)
   81 format(2x,'rt [m]  =',f12.6)
   82 format(2x,'ch [m]  =',f12.6)
   83 format(2x,'ct [m]  =',f12.6)
   84 format(2x,'pf [m]  =',f12.6)   
   85 format(2x,'h [%c]  =',f12.6)   
   86 format(2x,'numero de palas =',i3)   
!      if(index2.ne.0) write(50,8) rh,rt,ch,ct,pf,hc,npal
!    8 format(2x,'rh [m]  =',f12.6,/,
!     &       2x,'rt [m]  =',f12.6,/,
!     &       2x,'ch [m]  =',f12.6,/,
!     &       2x,'ct [m]  =',f12.6,/,
!     &       2x,'pf [m]  =',f12.6,//,   
!     &       2x,'h [%c]  =',f12.6,//,   
!     &       2x,'numero de palas =',i3,/)   
c     
      write(salida2out(nsld2),6) nr,no,np
      write(salida2out(nsld2+1),'(a1)') "" 
      write(salida2out(nsld2+2),61) npan,nodos
      write(salida2out(nsld2+3),'(a1)') "" 
      nsld2=nsld2+4
    6 format(2x,'Nr =',i3,9x,'No =',i3,9x,'Np =',i3)
   61 format(2x,'N paneles =',i9,9x,'   N nodos =',i9)
!      write(50,6) nr,no,np,npan,nodos
!    6 format(2x,'Nr =',i3,9x,'No =',i3,9x,'Np =',i3,//,
!     &       2x,'N paneles =',i9,9x,'   N nodos =',i9,/)
c      
      write(salida2out(nsld2),10)index0
      write(salida2out(nsld2+1),101) index1
      write(salida2out(nsld2+2),102) index2
      write(salida2out(nsld2+3),103) index3
      write(salida2out(nsld2+4),104) index4
      write(salida2out(nsld2+5),105) index5
      write(salida2out(nsld2+6),106) index6
      write(salida2out(nsld2+7),107) index7
      write(salida2out(nsld2+8),108) index8
      write(salida2out(nsld2+9),109) index9
      write(salida2out(nsld2+10),110) index10
      write(salida2out(nsld2+11),111) index11
      write(salida2out(nsld2+12),112) index12
      write(salida2out(nsld2+13),'(a1)') "" 
      nsld2=nsld2+14
   10 format(2x,'index0  =',i3)
  101 format(2x,'index1  =',i3)
  102 format(2x,'index2  =',i3)
  103 format(2x,'index3  =',i3)
  104 format(2x,'index4  =',i3)
  105 format(2x,'index5  =',i3)
  106 format(2x,'index6  =',i3)
  107 format(2x,'index7  =',i3)
  108 format(2x,'index8  =',i3)
  109 format(2x,'index9  =',i3)
  110 format(2x,'index10 =',i3)
  111 format(2x,'index11 =',i3)
  112 format(2x,'index12 =',i3)
!      write(50,10)index0,index1,index2,index3,index4,index5,index6,
!     &            index7,index8,index9,index10,index11,index12
!   10 format(2x,'index0  =',i3,/,
!     &       2x,'index1  =',i3,/,
!     &       2x,'index2  =',i3,/,
!     &       2x,'index3  =',i3,/,
!     &       2x,'index4  =',i3,/,
!     &       2x,'index5  =',i3,/,
!     &       2x,'index6  =',i3,/,
!     &       2x,'index7  =',i3,/,
!     &       2x,'index8  =',i3,/,
!     &       2x,'index9  =',i3,/,
!     &       2x,'index10 =',i3,/,
!     &       2x,'index11 =',i3,/,
!     &       2x,'index12 =',i3,/)
c
      return
      end
c
c-----------------------------------------------------------------------
c
      subroutine coord3d
c
c    coordenadas (x,y,z) de los nodos del dominio 3D alrededor de la 
c    pala 1
c
c.......................................................................
c>
      implicit real*8 (a-h,o-z)
c
      parameter (maxir=51,maxio=51,maxip=11,maxnk=2001,
     &          mxir=maxir-1,mxio=maxio-1,mxip=maxip-1,
     &          maxro=maxir*maxio,mxro=mxir*mxio,mxnk=maxnk-1)
c
      common r(maxir),o(maxio),chord(maxir),yarc(maxir,maxio)
      common px(maxro),py(maxro),pz(maxro)
      common xbf(maxir),ybf(maxir),zbf(maxir),rbf(maxir)
      common xe(maxir,maxnk),ye(maxir,maxnk),ze(maxir,maxnk),
     &       re(maxir,maxnk),fi(maxir,maxnk),fifa(mxro,5),fipri(mxro,5)
c     
      common p1x(mxro),p1y(mxro),p1z(mxro),      
     &       p2x(mxro),p2y(mxro),p2z(mxro),
     &       p3x(mxro),p3y(mxro),p3z(mxro),
     &       p4x(mxro),p4y(mxro),p4z(mxro),
     &       pax(mxro),pay(mxro),paz(mxro),
     &       pbx(mxro),pby(mxro),pbz(mxro)
c
      common pcx(mxro,maxip),pcy(mxro,maxip),pcz(mxro,maxip),
     &       area(mxro),ss1(mxro,maxip),ss2(mxro,maxip),
     &       vnx(mxro),vny(mxro),vnz(mxro),Vinf(mxro)
c
      common gamma(mxro),circ(maxro),carga(mxro),theta(1)  
      common ciex(mxro,maxir),ciey(mxro,maxir),ciez(mxro,maxir),
     &       cix1tmp(mxro*mxro),ciy1tmp(mxro*mxro),ciz1tmp(mxro*mxro),
     &       cix2tmp(mxro*mxro),ciy2tmp(mxro*mxro),ciz2tmp(mxro*mxro)
      common vix(mxro,maxip),viy(mxro,maxip),viz(mxro,maxip),
     &       vi(mxro,maxip),vtgx(mxro,maxip),vtgy(mxro,maxip),
     &       urx(mxro,maxip),ury(mxro,maxip),urz(mxro,maxip)     
      common urex(mxro),urey(mxro),urez(mxro),
     &       urix(mxro),uriy(mxro),uriz(mxro)
c
      common U,UU,omega,c0,a,rh,rt,oi,of,pf,ch,ct,zlim,factor1,factor2
      common pi,beta,cero,signo,redvel,coefa,hc,dfi,alfac,c1,c2,distan
      common indice,index0,index1,index2,index3,index4,index5,index6,      
     &       index7,index8,index9,index10,index11,index12,alfac0      
      common npan,nodos,ncapa,npal,npaso,nr,no,np,nk,kult,inic,in1,in2, 
     &       in3,nsubr,nsld2
c
      character integ1(maxro)*150,integ2(maxro)*150,gamastr(maxro)*70,
     &          circostr(maxro)*70,salida2out(102)*95
c     Variable para internal file del archivo global subr.out
c     el cual lleva los mismos datos que la salida standar
      character subrout(500)*60
c                      
                      
      common integ1,integ2,gamastr,circostr,subrout,salida2out
c
c< 
c.......................................................................
c
       if(index2.ne.0) goto 1
c            
c    p/index2 = 0
c
c    CASO A: coordenadas cilindricas (r,o,p)
c            pala: fragmento de helicoide 
c
c    mallado del dominio 3D con dr, do, dp constantes (index6,7 = 0)
c    o con variacion en r y o cosenoidal (index6,7 =/= 0)
c
      do 110 ir=1,nr+1
      if(index6.eq.0) r(ir)= rh+(rt-rh)*(ir-1)/nr 
c
      if(index6.ne.0) titar= (ir-1)*pi/nr
      if(index6.ne.0) r(ir)= rh+(rt-rh)*(1.-dcos(titar))/2.
  110 continue
c
      do 111 io=1,no+1
      if(index7.eq.0) o(io)= oi+(of-oi)*(io-1)/no   
c      
CCC      if(index7.lt.0) titao= (io-1)*pi/no
CCC      if(index7.lt.0) o(io)= oi+(of-oi)*(1.-dcos(titao))/2.
c                             
      if(index7.ge.0) goto 109
      bet0   = beta-1.
      bet1   = beta+1.
      relbet = bet1/bet0
      valor0 = 1.-1.*(io-1)/no 
      valor1 = relbet**valor0
       o(io) = oi+(bet1-bet0*valor1)/(valor1+1.) 
  109 continue     
c
      if(index7.gt.0) titao= (io-1)*(pi/2.)/no
      if(index7.gt.0) o(io)= oi+(of-oi)*(1.-dcos(titao))
  111 continue
c
c    coordenadas en xyz (volumen sobre la pala 1)
c         
c    tg(fi) = r/a     
c
ccc      x1(ir,io,ip)= r(ir)*dcos(o(io))+p(ip)*dsin(o(io))*cosfi 
ccc      y1(ir,io,ip)= r(ir)*dsin(o(io))-p(ip)*dcos(o(io))*cosfi
ccc      z1(ir,io,ip)= a*o(io)+p(ip)*senfi
c                
      goto 2  
c 
c/////////////////////////////////////////////////////////////////////// 
c
    1 continue     
      if(index2.lt.0) goto 100
c                
c    si index2 > 0, pala sin curvatura
c
c    CASO B1: coordenadas rectangulares (r,c,p)
c             pala: fragmento de placa alabeada, de cuerda variable
c                   linealmente, y flecha de Borde de Ataque nula
c
c    mallado del dominio 3D con dr, dc=do, dp constantes (index6,7 = 0)
c    o con variacion en r y o cosenoidal (index6,7 =/= 0)
c                          
      do 210 ir=1,nr+1
      if(index6.eq.0) r(ir)= rh+(rt-rh)*(ir-1)/nr 
c
      if(index6.ne.0) titar= (ir-1)*pi/nr
      if(index6.ne.0) r(ir)= rh+(rt-rh)*(1.-dcos(titar))/2.
c      
      chord(ir)=ch-(ch-ct)*(r(ir)-rh)/rt
  210 continue
c
      do 211 io=1,no+1
      if(index7.eq.0) o(io)= 1.*(io-1)/no   
c      
CCC      if(index7.lt.0) titao= (io-1)*pi/no
CCC      if(index7.lt.0) o(io)= oi+(of-oi)*(1.-dcos(titao))/2.
c                             
      if(index7.ge.0) goto 201
      bet0   = beta-1.
      bet1   = beta+1.
      relbet = bet1/bet0
      valor0 = 1.-1.*(io-1)/no 
      valor1 = relbet**valor0
       o(io) = oi+(bet1-bet0*valor1)/(valor1+1.) 
  201 continue     
c
      if(index7.gt.0) titao= (io-1)*(pi/2.)/no
      if(index7.gt.0) o(io)= (1.-dcos(titao))
  211 continue
cc
c    coordenadas en xyz (volumen sobre la pala 1)
c         
c    tg(psi) = a/r = coefa*UU/rW   o   UU/rW    o   U/rW
c
c    psi: angulo de la cuerda local respecto del plano xy
c
      goto 2
c
c///////////////////////////////////////////////////////////////////////
c
  100 continue
c                             
c    si index2 < 0, perfil de arco circular
c                   rac: radio del arco circular
c                   hc: flecha/cuerda
c
c    CASO B2: coordenadas rectangulares (r,c,p)
c             pala: fragmento de placa alabeada, de cuerda variable
c                   linealmente, y flecha de Borde de Ataque nula
c
c    mallado del dominio 3D con dr, dc=do, dp constantes (index6,7 = 0)
c    o con variacion en r y o cosenoidal (index6,7 =/= 0)
c                          
      do 310 ir=1,nr+1
      if(index6.eq.0) r(ir)= rh+(rt-rh)*(ir-1)/nr 
c
      if(index6.ne.0) titar= (ir-1)*pi/nr
      if(index6.ne.0) r(ir)= rh+(rt-rh)*(1.-dcos(titar))/2.
c      
      chord(ir)=ch-(ch-ct)*(r(ir)-rh)/rt
  310 continue
c
      do 311 io=1,no+1
      if(index7.eq.0) o(io)= 1.*(io-1)/no   
c      
CCC      if(index7.lt.0) titao= (io-1)*pi/no
CCC      if(index7.lt.0) o(io)= oi+(of-oi)*(1.-dcos(titao))/2.
c                             
      if(index7.ge.0) goto 301
      bet0   = beta-1.
      bet1   = beta+1.
      relbet = bet1/bet0
      valor0 = 1.-1.*(io-1)/no 
      valor1 = relbet**valor0
       o(io) = oi+(bet1-bet0*valor1)/(valor1+1.) 
  301 continue     
c
      if(index7.gt.0) titao= (io-1)*(pi/2.)/no
      if(index7.gt.0) o(io)= (1.-dcos(titao))
  311 continue
c
c    segmento de arco circular [(x-x0)/c]^2 + [(y-y0)/c]^2 = (R/c)^2 
c
c    x0/c = 1/2       y0/c = (H-R)/c      hc = H/c 
c
c    H: flecha        c: cuerda local     R: radio de la circunferencia
c
      y0c= (0.5*hc)-1./(8.*hc)
      rarc=(0.5*hc)+1./(8.*hc)     
c
      yarc(ir,1) = cero
      yarc(ir,no+1)= cero                       
      do 316 ir=1,nr+1
      do 317 io=2,no          
      raizc=rarc**2-(o(io)-0.5)**2
      yarc(ir,io)=(y0c+dsqrt(raizc))*chord(ir)
  317 continue
  316 continue 
c
      do 318 io=1,no+1
      write(26,319)(o(io)*chord(ir),yarc(ir,io),ir=1,nr+1,5)
!      if(io.eq.no)
!     & write(arcotxt(1),319)(o(io)*chord(ir),yarc(ir,io),ir=1,nr+1,5)
  318 continue
  319 format(2x,6(f6.3,1x,f6.3,1x))           
c
c    coordenadas en xyz (volumen sobre la pala 1)
c         
c    tg(psi) = a/r = coefa*UU/rW   o   UU/rW    o   U/rW
c
c    psi: angulo de la cuerda local respecto del plano xy
c
ccc      perp=p(ip)+yarc(ir,io)
c
ccc      x1(ir,io,ip)= r(ir) 
ccc      y1(ir,io,ip)= chord(ir)*o(io)*cospsi-perp*senpsi
ccc      z1(ir,io,ip)= chord(ir)*o(io)*senpsi+perp*cospsi
c
    2 continue   
c
c///////////////////////////////////////////////////////////////////////
c
      return
      end
c
c-----------------------------------------------------------------------
c
      subroutine palas                             
c      
c    coordenadas de las esquinas de los paneles de la pala
c
c.......................................................................
c>
      implicit real*8 (a-h,o-z)
c
      parameter (maxir=51,maxio=51,maxip=11,maxnk=2001,
     &          mxir=maxir-1,mxio=maxio-1,mxip=maxip-1,
     &          maxro=maxir*maxio,mxro=mxir*mxio,mxnk=maxnk-1)
c
      common r(maxir),o(maxio),chord(maxir),yarc(maxir,maxio)
      common px(maxro),py(maxro),pz(maxro)
      common xbf(maxir),ybf(maxir),zbf(maxir),rbf(maxir)
      common xe(maxir,maxnk),ye(maxir,maxnk),ze(maxir,maxnk),
     &       re(maxir,maxnk),fi(maxir,maxnk),fifa(mxro,5),fipri(mxro,5)
c     
      common p1x(mxro),p1y(mxro),p1z(mxro),      
     &       p2x(mxro),p2y(mxro),p2z(mxro),
     &       p3x(mxro),p3y(mxro),p3z(mxro),
     &       p4x(mxro),p4y(mxro),p4z(mxro),
     &       pax(mxro),pay(mxro),paz(mxro),
     &       pbx(mxro),pby(mxro),pbz(mxro)
c
      common pcx(mxro,maxip),pcy(mxro,maxip),pcz(mxro,maxip),
     &       area(mxro),ss1(mxro,maxip),ss2(mxro,maxip),
     &       vnx(mxro),vny(mxro),vnz(mxro),Vinf(mxro)
c
      common gamma(mxro),circ(maxro),carga(mxro),theta(1)  
      common ciex(mxro,maxir),ciey(mxro,maxir),ciez(mxro,maxir),
     &       cix1tmp(mxro*mxro),ciy1tmp(mxro*mxro),ciz1tmp(mxro*mxro),
     &       cix2tmp(mxro*mxro),ciy2tmp(mxro*mxro),ciz2tmp(mxro*mxro)
      common vix(mxro,maxip),viy(mxro,maxip),viz(mxro,maxip),
     &       vi(mxro,maxip),vtgx(mxro,maxip),vtgy(mxro,maxip),
     &       urx(mxro,maxip),ury(mxro,maxip),urz(mxro,maxip)     
      common urex(mxro),urey(mxro),urez(mxro),
     &       urix(mxro),uriy(mxro),uriz(mxro)
c
      common U,UU,omega,c0,a,rh,rt,oi,of,pf,ch,ct,zlim,factor1,factor2
      common pi,beta,cero,signo,redvel,coefa,hc,dfi,alfac,c1,c2,distan
      common indice,index0,index1,index2,index3,index4,index5,index6,      
     &       index7,index8,index9,index10,index11,index12,alfac0      
      common npan,nodos,ncapa,npal,npaso,nr,no,np,nk,kult,inic,in1,in2, 
     &       in3,nsubr,nsld2
c
      character integ1(maxro)*150,integ2(maxro)*150,gamastr(maxro)*70,
     &          circostr(maxro)*70,salida2out(102)*95
c     Variable para internal file del archivo global subr.out
c     el cual lleva los mismos datos que la salida standar
      character subrout(500)*60
c                      
                      
      common integ1,integ2,gamastr,circostr,subrout,salida2out
c
c<
c.......................................................................
c      
      dimension xp(maxir,maxio),yp(maxir,maxio),zp(maxir,maxio)
      dimension psir(maxir)
c      
c.......................................................................
c             
      dtheta=2.*pi/npal
      do 301 ib=1,npal
      theta(ib)=(ib-1)*dtheta                       
  301 continue                            
c
      write(8,1)
      write(52,1)
    1 format(1x,'TITLE = "PALAS" ')
      write(8,2)
      write(52,2)
    2 format(1x,'Variables = "x", "y", "z" ')
c
c     ploteo de las npal palas de la turbina
c
CCC      do 12 ib=1,npal
      ib=1  
c  
      write(8,3)ib,nodos,npan
      write(52,3)ib,nodos,npan
    3 format(1x,'Zone T="',i2,'", N=',i6,', E=',i5,
     &               ', F=FEPOINT, ET=QUADRILATERAL')          
c
c    coordenadas xyz de la pala (p = 0)
c                
      do 14 io=1,no+1
      do 13 ir=1,nr+1                                        
c
c///////////////////////////////////////////////////////////////////////      
c             
c     CASO A:
c     segmento de helicoide  (p/index2 = 0)
c      
      if(index2.ne.0) goto 11          
      xp(ir,io)= r(ir)*dcos(o(io)+theta(ib))
      yp(ir,io)= r(ir)*dsin(o(io)+theta(ib))
      zp(ir,io)= a*o(io)
      goto 10   
c      
   11 continue  
      if(index2.lt.0) goto 15                     
c
c///////////////////////////////////////////////////////////////////////      
c            
c     CASO B1:
c     cuerda variable y flecha de BA nula, placas planas (p/index2 > 0)
c  
      if(ib.gt.1)goto 27
c
      if(index9.eq.0) psir(ir)=datan(a/r(ir))   
      if(index9.ne.0) psir(ir)=datan(UU/(omega*r(ir)))-alfac*r(ir)/rt
     &                                                -alfac0
      senpsi=dsin(psir(ir))
      cospsi=dcos(psir(ir))         
c
      xp(ir,io)= r(ir) 
      yp(ir,io)= chord(ir)*o(io)*cospsi
      zp(ir,io)= chord(ir)*o(io)*senpsi
c
      goto 17
   27 continue   
c   
      xp(ir,io)= xp(ir,io)*dcos(theta(ib))-
     &           yp(ir,io)*dsin(theta(ib)) 
      yp(ir,io)= xp(ir,io)*dsin(theta(ib))+ 
     &           yp(ir,io)*dcos(theta(ib)) 
      zp(ir,io)= zp(ir,io)
c       
   17 continue 
      goto 10
c
c///////////////////////////////////////////////////////////////////////      
c            
c     CASO B2:
c     cuerda variable y flecha de BA nula, arco circular (p/index2 < 0)
c
   15 continue        
c  
      if(ib.gt.1)goto 28
c
      if(index9.eq.0) psir(ir)=datan(a/r(ir))   
      if(index9.ne.0) psir(ir)=datan(UU/(omega*r(ir)))-alfac*r(ir)/rt   
     &                                                -alfac0
      senpsi=dsin(psir(ir))
      cospsi=dcos(psir(ir))         
c                                             
      xp(ir,io)= r(ir) 
      yp(ir,io)= chord(ir)*o(io)*cospsi-yarc(ir,io)*senpsi
      zp(ir,io)= chord(ir)*o(io)*senpsi+yarc(ir,io)*cospsi
c
      goto 18
   28 continue  
c    
      xp(ir,io)= xp(ir,io)*dcos(theta(ib))-
     &           yp(ir,io)*dsin(theta(ib)) 
      yp(ir,io)= xp(ir,io)*dsin(theta(ib))+ 
     &           yp(ir,io)*dcos(theta(ib)) 
      zp(ir,io)= zp(ir,io) 
c
   18 continue   
c       
c///////////////////////////////////////////////////////////////////////      
c       
   10 continue   
c
   13 continue
   14 continue                                       
c
c    coordenadas de los nodos ubicados sobre cada pala, 
c    nn: numero de nodo de las esquinas del panel
c            
      do 47 io=1,no+1
      do 48 ir=1,nr+1
c      
      nn=ir+(io-1)*(nr+1)
c
      px(nn)=xp(ir,io)
      py(nn)=yp(ir,io)
      pz(nn)=zp(ir,io)
c
      write(8,8) px(nn),py(nn),pz(nn)
      write(52,8)px(nn),py(nn),pz(nn)
c
   48 continue
   47 continue
    8 format(1x,3(2x,f12.6))
c
c    conectividades
c      
      write(8,7)
      write(52,7)
c
      do 25 io=1,no
      do 26 ir=1,nr
c
      nn=ir+(io-1)*(nr+1)
c      
      n1=nn
      n2=nn+1
      n3=nn+(nr+2)
      n4=nn+(nr+1)
c
      write(8,5) n1,n2,n3,n4
      write(52,5)n1,n2,n3,n4
   26 continue
   25 continue
    5 format(1x,4(i6,1x))    
      write(8,7)
      write(52,7)
c
   12 continue      
    7 format(2x)
c                                                 
c    coordenadas contorno pala
c   
      do 922 io=1,no+1
      write(19,22) xp(1,io),yp(1,io),zp(1,io),cero
  922 continue    
c 
c.......................................................................    
c
c    coordenadas del los puntos en borde de fuga de cada pala
c    y radio local del tubo de corriente, rbf. 
c       
CCC      do 23 ib=1,npal 
      ib=1
c                                             
      do 45 ir=1,nr+1
      xbf(ir)= xp(ir,no+1)
      ybf(ir)= yp(ir,no+1)
      zbf(ir)= zp(ir,no+1)  
      if(ib.eq.1) rbf2= xbf(ir)**2+ybf(ir)**2
      if(ib.eq.1) rbf(ir)= dsqrt(rbf2) 
      if(ib.eq.1) write(19,22)
     &            xbf(ir),ybf(ir),zbf(ir),rbf(ir)
   45 continue     
   23 continue                              
c   
      do 923 io=1,no+1
      write(19,22) xp(nr+1,no+2-io),yp(nr+1,no+2-io),
     &             zp(nr+1,no+2-io),cero
  923 continue    
c   
      do 924 ir=1,nr+1
      write(19,22) xp(nr+2-ir,1),yp(nr+2-ir,1),zp(nr+2-ir,1),cero
  924 continue    
c 
   22 format(1x,4(1x,f9.4))
c                             
c    determinacion de los angulos de incidencia locales, medidos respecto
c    de cuerda (p/index2 =/= 0)
c
      if(index2.eq.0) goto 900
c          
      ccttee=180./pi
c
      do 800 ir=1,nr+1
      tgfi1= U/(omega*r(ir))  
      angfi1=datan(tgfi1)    
      tgfi2=UU/(omega*r(ir))  
      angfi2=datan(tgfi2) 
      tgfi3=coefa*UU/(omega*r(ir))  
      angfi3=datan(tgfi3) 
      alfa12=angfi1-angfi2
      alfa23=angfi2-angfi3
      alfaco=angfi2-psir(ir)
      write(51,700)ir,r(ir),r(ir)/rt,
     &             angfi1*ccttee,angfi2*ccttee,angfi3*ccttee,
     &             alfa12*ccttee,alfa23*ccttee,psir(ir)*ccttee,
     &             alfaco*ccttee      
  800 continue    
  700 format(1x,i4,9(f12.6))
c
  900 continue    
c
      return
      end
c
c-----------------------------------------------------------------------
c
      subroutine panel(outstd,tam)
c      
c    Coordenadas de los nodos en los paneles  
c    Versores normales a cada panel
c
c    PRIMERA PARTE:
c       
c    Puntos de colocacion en 3c/4 de cada panel  (INDICE = 1)
c
c    Puntos de calculo en c/2 de cada panel      (INDICE = 3)
c
c.......................................................................
c>
      implicit real*8 (a-h,o-z)
c
      parameter (maxir=51,maxio=51,maxip=11,maxnk=2001,
     &          mxir=maxir-1,mxio=maxio-1,mxip=maxip-1,
     &          maxro=maxir*maxio,mxro=mxir*mxio,mxnk=maxnk-1)
c
      common r(maxir),o(maxio),chord(maxir),yarc(maxir,maxio)
      common px(maxro),py(maxro),pz(maxro)
      common xbf(maxir),ybf(maxir),zbf(maxir),rbf(maxir)
      common xe(maxir,maxnk),ye(maxir,maxnk),ze(maxir,maxnk),
     &       re(maxir,maxnk),fi(maxir,maxnk),fifa(mxro,5),fipri(mxro,5)
c     
      common p1x(mxro),p1y(mxro),p1z(mxro),      
     &       p2x(mxro),p2y(mxro),p2z(mxro),
     &       p3x(mxro),p3y(mxro),p3z(mxro),
     &       p4x(mxro),p4y(mxro),p4z(mxro),
     &       pax(mxro),pay(mxro),paz(mxro),
     &       pbx(mxro),pby(mxro),pbz(mxro)
c
      common pcx(mxro,maxip),pcy(mxro,maxip),pcz(mxro,maxip),
     &       area(mxro),ss1(mxro,maxip),ss2(mxro,maxip),
     &       vnx(mxro),vny(mxro),vnz(mxro),Vinf(mxro)
c
      common gamma(mxro),circ(maxro),carga(mxro),theta(1)  
      common ciex(mxro,maxir),ciey(mxro,maxir),ciez(mxro,maxir),
     &       cix1tmp(mxro*mxro),ciy1tmp(mxro*mxro),ciz1tmp(mxro*mxro),
     &       cix2tmp(mxro*mxro),ciy2tmp(mxro*mxro),ciz2tmp(mxro*mxro)
      common vix(mxro,maxip),viy(mxro,maxip),viz(mxro,maxip),
     &       vi(mxro,maxip),vtgx(mxro,maxip),vtgy(mxro,maxip),
     &       urx(mxro,maxip),ury(mxro,maxip),urz(mxro,maxip)     
      common urex(mxro),urey(mxro),urez(mxro),
     &       urix(mxro),uriy(mxro),uriz(mxro)
c
      common U,UU,omega,c0,a,rh,rt,oi,of,pf,ch,ct,zlim,factor1,factor2
      common pi,beta,cero,signo,redvel,coefa,hc,dfi,alfac,c1,c2,distan
      common indice,index0,index1,index2,index3,index4,index5,index6,      
     &       index7,index8,index9,index10,index11,index12,alfac0      
      common npan,nodos,ncapa,npal,npaso,nr,no,np,nk,kult,inic,in1,in2, 
     &       in3,nsubr,nsld2
c
      character integ1(maxro)*150,integ2(maxro)*150,gamastr(maxro)*70,
     &          circostr(maxro)*70,salida2out(102)*95
c     Variable para internal file del archivo global subr.out
c     el cual lleva los mismos datos que la salida standar
      character subrout(500)*60
c                      
                      
      common integ1,integ2,gamastr,circostr,subrout,salida2out
c
c<
      integer tam
      character outstd(50)*100
!  OUTSTD es un array de caracteres para llevar la salida estandar de la 
!  subrutina, en lugar de hacer write(6). Se difiere su escritura en 
!  pantalla hasta volver al programa Main. 
!  TAM lleva la cantidad de posiciones utilizadas en OUTSTD
!  Ambas variables van por parametro en el nombre de la subrutina.
c.......................................................................
c
c    nodos y puntos intermedios de cada panel
c    npa = numero de panel          
c
      tam=1
c
      write(11,11)
   11 format(2x,'No de panel, num.interna, p(x,y,z)',/)  
c             
CCC      do 17 ib=1,npal
      ib=1
c         
      write(subrout(nsubr),13)ib,npal
      nsubr=nsubr+1
!      write(15,13)ib,npal
!      write(6,13) ib,npal
      write(outstd(tam),13) ib,npal
      tam=tam+1
   13 format(20x,'pala',i3,' de',i3)   
!      if(ib.eq.npal) write(subrout(nsubr),31)  
!      if(ib.eq.npal) nsubr=nsubr+1
!      write(15,31)  
!      if(ib.eq.npal) write(6,31) 
      if(ib.eq.npal) write(outstd(tam),31) 
      if(ib.eq.npal) tam=tam+1 
   31 format(2x)    
c      
      do 15 io=1,no
      do 16 ir=1,nr
c
      npa=ir+(io-1)*nr
       nn=ir+(io-1)*(nr+1)
c      
      n1=nn
      n2=nn+1
      n3=nn+(nr+2)
      n4=nn+(nr+1)
      
      p1x(npa)= px(n1)
      p1y(npa)= py(n1)
      p1z(npa)= pz(n1)
c       
      p2x(npa)= px(n2)
      p2y(npa)= py(n2)
      p2z(npa)= pz(n2)
c       
      p3x(npa)= px(n3)
      p3y(npa)= py(n3)
      p3z(npa)= pz(n3)
c       
      p4x(npa)= px(n4)
      p4y(npa)= py(n4)
      p4z(npa)= pz(n4)
c
      p5x=      p1x(npa)+0.25*(p4x(npa)-p1x(npa))
      p5y=      p1y(npa)+0.25*(p4y(npa)-p1y(npa))
      p5z=      p1z(npa)+0.25*(p4z(npa)-p1z(npa))
      pax(npa)= p5x
      pay(npa)= p5y
      paz(npa)= p5z
c
      p6x=      p2x(npa)+0.25*(p3x(npa)-p2x(npa))
      p6y=      p2y(npa)+0.25*(p3y(npa)-p2y(npa))
      p6z=      p2z(npa)+0.25*(p3z(npa)-p2z(npa))
      pbx(npa)= p6x
      pby(npa)= p6y
      pbz(npa)= p6z
c
      p7x=      p1x(npa)+0.75*(p4x(npa)-p1x(npa))
      p7y=      p1y(npa)+0.75*(p4y(npa)-p1y(npa))
      p7z=      p1z(npa)+0.75*(p4z(npa)-p1z(npa))
c               
      p8x=      p2x(npa)+0.75*(p3x(npa)-p2x(npa))
      p8y=      p2y(npa)+0.75*(p3y(npa)-p2y(npa))
      p8z=      p2z(npa)+0.75*(p3z(npa)-p2z(npa))
c      
      p9x=      p1x(npa)+0.50*(p2x(npa)-p1x(npa))
      p9y=      p1y(npa)+0.50*(p2y(npa)-p1y(npa))
      p9z=      p1z(npa)+0.50*(p2z(npa)-p1z(npa))
c
      p10x=     p4x(npa)+0.50*(p3x(npa)-p4x(npa))
      p10y=     p4y(npa)+0.50*(p3y(npa)-p4y(npa))
      p10z=     p4z(npa)+0.50*(p3z(npa)-p4z(npa))
c
c    coordenadas del punto de colocacion a 3c/4 del panel, Pc (capa No.1)   
c
      p11x=      p7x+0.50*(p8x-p7x)
      p11y=      p7y+0.50*(p8y-p7y)
      p11z=      p7z+0.50*(p8z-p7z)
c        
      if(ib.ne.1) goto 18
c      
      if(indice.eq.3) goto 69
      pcx(npa,1)=p9x+0.75*(p10x-p9x)
      pcy(npa,1)=p9y+0.75*(p10y-p9y)
      pcz(npa,1)=p9z+0.75*(p10z-p9z)
      goto 96   
c
c    coordenadas del punto de colocacion a c/2 del panel, Pc (capa No.1) 
c
c    IF: indice = 3, inic = 1 
c                                     
   69 continue
      pcx(npa,1)=p9x+0.50*(p10x-p9x)
      pcy(npa,1)=p9y+0.50*(p10y-p9y)
      pcz(npa,1)=p9z+0.50*(p10z-p9z)   
   96 continue   
c      
c.....................................................................
c
c    determinacion del versor normal al panel, vn = (vnx,vny,vnz) y
c    del area del panel
c
      ax=p8x -p7x
      ay=p8y -p7y
      az=p8z -p7z
c
      bx=p10x-p9x
      by=p10y-p9y
      bz=p10z-p9z
c
c     c = a x b
c
      cx=bz*ay-by*az
      cy=bx*az-bz*ax
      cz=by*ax-bx*ay
c
      vnmod2=cx**2+cy**2+cz**2
      vnmod =dsqrt(vnmod2)                 
      area(npa)= vnmod
c
      vnx(npa)=cx/vnmod
      vny(npa)=cy/vnmod
      vnz(npa)=cz/vnmod
c      
c.....................................................................
c
   18 continue
c
      numero=0
      write(11,21) npa,numero+1,p1x(npa),p1y(npa),p1z(npa)
      write(11,21) npa,numero+2,p2x(npa),p2y(npa),p2z(npa)
      write(11,21) npa,numero+3,p3x(npa),p3y(npa),p3z(npa)
      write(11,21) npa,numero+4,p4x(npa),p4y(npa),p4z(npa)
      write(11,21) npa,numero+5,pax(npa),pay(npa),paz(npa)
      write(11,21) npa,numero+6,pbx(npa),pby(npa),pbz(npa)
      write(11,21) npa,numero+7,pcx(npa,1), pcy(npa,1), pcz(npa,1)
      write(11,21) npa,numero+7,p11x,p11y,p11z
      write(20,22) npa,vnx(npa),vny(npa),vnz(npa),
     &             vnx(npa)**2+vny(npa)**2+vnz(npa)**2 
      write(11,23)
c             
   16 continue
   15 continue
   17 continue
c
   21 format(1x,i6,2x,i3,3(1x,f11.6)) 
   22 format(1x,i6,5x,4(1x,f10.6)) 
c
      write(10,1)
    1 format(1x,'TITLE = "PANELES PALA No.1" ')
      write(10,2)
    2 format(1x,'Variables = "x", "y", "z" ')
      write(10,3)8*npan,2*npan  
    3 format(1x,'Zone N=',i6,', E=',i5,', F=FEPOINT, ET=QUADRILATERAL') 
c
c     Representacion de dos "anillos" por panel
c     1-2-3-4     y       a-b-3-4
c
      do 25 io=1,no
      do 26 ir=1,nr
c      
      npa=ir+(io-1)*nr
c
      write(10,20) p1x(npa),p1y(npa),p1z(npa)
      write(10,20) p2x(npa),p2y(npa),p2z(npa)
      write(10,20) p3x(npa),p3y(npa),p3z(npa)
      write(10,20) p4x(npa),p4y(npa),p4z(npa)
c
   26 continue
   25 continue
c
      do 35 io=1,no
      do 36 ir=1,nr
c      
      npa=ir+(io-1)*nr
c      
      write(10,20) pax(npa),pay(npa),paz(npa)
      write(10,20) pbx(npa),pby(npa),pbz(npa)
      write(10,20) p3x(npa),p3y(npa),p3z(npa)
      write(10,20) p4x(npa),p4y(npa),p4z(npa)
c      
   36 continue   
   35 continue
c   
   20 format(1x,3(1x,f11.6)) 
      write(10,23)
c
c     conectividades  
c
      do 45 k=1,npan
c                 
      nn=1+4*(k-1)
c      
      n1=nn
      n2=nn+1
      n3=nn+2
      n4=nn+3
c
      write(10,27)n1,n2,n3,n4
c      
   45 continue  
c
      nult=n4   
c
      do 55 k=1,npan
c      
      nn=1+4*(k-1)+nult
c      
      n1=nn
      n2=nn+1
      n3=nn+2
      n4=nn+3
c
      write(10,27)n1,n2,n3,n4
c      
   55 continue
c   
   27 format(1x,4(1x,i7)) 
   23 format(2x)
c      
      return
      end
c
c-----------------------------------------------------------------------
c
      subroutine hilo
c                     
c    SEGUNDA PARTE:  
c  
c    Puntos de colocacion sobre la mitad del hilo vorticoso ligado al 
c    panel, u otros. 
c
c.......................................................................
c>
      implicit real*8 (a-h,o-z)
c
      parameter (maxir=51,maxio=51,maxip=11,maxnk=2001,
     &          mxir=maxir-1,mxio=maxio-1,mxip=maxip-1,
     &          maxro=maxir*maxio,mxro=mxir*mxio,mxnk=maxnk-1)
c
      common r(maxir),o(maxio),chord(maxir),yarc(maxir,maxio)
      common px(maxro),py(maxro),pz(maxro)
      common xbf(maxir),ybf(maxir),zbf(maxir),rbf(maxir)
      common xe(maxir,maxnk),ye(maxir,maxnk),ze(maxir,maxnk),
     &       re(maxir,maxnk),fi(maxir,maxnk),fifa(mxro,5),fipri(mxro,5)
c     
      common p1x(mxro),p1y(mxro),p1z(mxro),      
     &       p2x(mxro),p2y(mxro),p2z(mxro),
     &       p3x(mxro),p3y(mxro),p3z(mxro),
     &       p4x(mxro),p4y(mxro),p4z(mxro),
     &       pax(mxro),pay(mxro),paz(mxro),
     &       pbx(mxro),pby(mxro),pbz(mxro)
c
      common pcx(mxro,maxip),pcy(mxro,maxip),pcz(mxro,maxip),
     &       area(mxro),ss1(mxro,maxip),ss2(mxro,maxip),
     &       vnx(mxro),vny(mxro),vnz(mxro),Vinf(mxro)
c
      common gamma(mxro),circ(maxro),carga(mxro),theta(1)  
      common ciex(mxro,maxir),ciey(mxro,maxir),ciez(mxro,maxir),
     &       cix1tmp(mxro*mxro),ciy1tmp(mxro*mxro),ciz1tmp(mxro*mxro),
     &       cix2tmp(mxro*mxro),ciy2tmp(mxro*mxro),ciz2tmp(mxro*mxro)
      common vix(mxro,maxip),viy(mxro,maxip),viz(mxro,maxip),
     &       vi(mxro,maxip),vtgx(mxro,maxip),vtgy(mxro,maxip),
     &       urx(mxro,maxip),ury(mxro,maxip),urz(mxro,maxip)     
      common urex(mxro),urey(mxro),urez(mxro),
     &       urix(mxro),uriy(mxro),uriz(mxro)
c
      common U,UU,omega,c0,a,rh,rt,oi,of,pf,ch,ct,zlim,factor1,factor2
      common pi,beta,cero,signo,redvel,coefa,hc,dfi,alfac,c1,c2,distan
      common indice,index0,index1,index2,index3,index4,index5,index6,      
     &       index7,index8,index9,index10,index11,index12,alfac0      
      common npan,nodos,ncapa,npal,npaso,nr,no,np,nk,kult,inic,in1,in2, 
     &       in3,nsubr,nsld2
c
      character integ1(maxro)*150,integ2(maxro)*150,gamastr(maxro)*70,
     &          circostr(maxro)*70,salida2out(102)*95
c     Variable para internal file del archivo global subr.out
c     el cual lleva los mismos datos que la salida standar
      character subrout(500)*60
c                      
                      
      common integ1,integ2,gamastr,circostr,subrout,salida2out
c
c<
c.......................................................................
c
      do 15 io = 1,no
      do 16 ir = 1,nr
c
      npa = ir+(io-1)*nr
c
c    coordenadas del punto de colocacion Pc, de la pala 1 (capa No.10):
c
c    P1 si index11=1        c/4 si index11 = 0         P2 si index11=2  
c    P3 si index11=3        c/4 si index11 = 0         P4 si index11=4  
c
      if(index11.le.0) pcx(npa,10) = pax(npa)+0.50*(pbx(npa)-pax(npa))
      if(index11.le.0) pcy(npa,10) = pay(npa)+0.50*(pby(npa)-pay(npa))
      if(index11.le.0) pcz(npa,10) = paz(npa)+0.50*(pbz(npa)-paz(npa))
c
      if(index11.eq.1) pcx(npa,10) = p1x(npa)
      if(index11.eq.1) pcy(npa,10) = p1y(npa)
      if(index11.eq.1) pcz(npa,10) = p1z(npa)
c
      if(index11.eq.2) pcx(npa,10) = p2x(npa)
      if(index11.eq.2) pcy(npa,10) = p2y(npa)
      if(index11.eq.3) pcz(npa,10) = p2z(npa)
c
      if(index11.eq.3) pcx(npa,10) = p3x(npa)
      if(index11.eq.3) pcy(npa,10) = p3y(npa)
      if(index11.eq.3) pcz(npa,10) = p3z(npa)
c
      if(index11.ge.4) pcx(npa,10) = p4x(npa)
      if(index11.ge.4) pcy(npa,10) = p4y(npa)
      if(index11.ge.4) pcz(npa,10) = p4z(npa)
c                                             
   16 continue
   15 continue
c   
      return
      end
c
c-----------------------------------------------------------------------
c
      subroutine puntos1
c                     
c    TERCERA PARTE:  
c  
c    Puntos de calculo sobre la normal (a +- fracciones de distan)
c
c.......................................................................
c>
      implicit real*8 (a-h,o-z)
c
      parameter (maxir=51,maxio=51,maxip=11,maxnk=2001,
     &          mxir=maxir-1,mxio=maxio-1,mxip=maxip-1,
     &          maxro=maxir*maxio,mxro=mxir*mxio,mxnk=maxnk-1)
c
      common r(maxir),o(maxio),chord(maxir),yarc(maxir,maxio)
      common px(maxro),py(maxro),pz(maxro)
      common xbf(maxir),ybf(maxir),zbf(maxir),rbf(maxir)
      common xe(maxir,maxnk),ye(maxir,maxnk),ze(maxir,maxnk),
     &       re(maxir,maxnk),fi(maxir,maxnk),fifa(mxro,5),fipri(mxro,5)
c     
      common p1x(mxro),p1y(mxro),p1z(mxro),      
     &       p2x(mxro),p2y(mxro),p2z(mxro),
     &       p3x(mxro),p3y(mxro),p3z(mxro),
     &       p4x(mxro),p4y(mxro),p4z(mxro),
     &       pax(mxro),pay(mxro),paz(mxro),
     &       pbx(mxro),pby(mxro),pbz(mxro)
c
      common pcx(mxro,maxip),pcy(mxro,maxip),pcz(mxro,maxip),
     &       area(mxro),ss1(mxro,maxip),ss2(mxro,maxip),
     &       vnx(mxro),vny(mxro),vnz(mxro),Vinf(mxro)
c
      common gamma(mxro),circ(maxro),carga(mxro),theta(1)  
      common ciex(mxro,maxir),ciey(mxro,maxir),ciez(mxro,maxir),
     &       cix1tmp(mxro*mxro),ciy1tmp(mxro*mxro),ciz1tmp(mxro*mxro),
     &       cix2tmp(mxro*mxro),ciy2tmp(mxro*mxro),ciz2tmp(mxro*mxro)
      common vix(mxro,maxip),viy(mxro,maxip),viz(mxro,maxip),
     &       vi(mxro,maxip),vtgx(mxro,maxip),vtgy(mxro,maxip),
     &       urx(mxro,maxip),ury(mxro,maxip),urz(mxro,maxip)     
      common urex(mxro),urey(mxro),urez(mxro),
     &       urix(mxro),uriy(mxro),uriz(mxro)
c
      common U,UU,omega,c0,a,rh,rt,oi,of,pf,ch,ct,zlim,factor1,factor2
      common pi,beta,cero,signo,redvel,coefa,hc,dfi,alfac,c1,c2,distan
      common indice,index0,index1,index2,index3,index4,index5,index6,      
     &       index7,index8,index9,index10,index11,index12,alfac0      
      common npan,nodos,ncapa,npal,npaso,nr,no,np,nk,kult,inic,in1,in2, 
     &       in3,nsubr,nsld2
c
      character integ1(maxro)*150,integ2(maxro)*150,gamastr(maxro)*70,
     &          circostr(maxro)*70,salida2out(102)*95
c     Variable para internal file del archivo global subr.out
c     el cual lleva los mismos datos que la salida standar
      character subrout(500)*60
c                      
                      
      common integ1,integ2,gamastr,circostr,subrout,salida2out
c
c<
c.......................................................................
c
      do 15 io=1,no
      do 16 ir=1,nr
c
      npa=ir+(io-1)*nr
c
c    coordenadas del punto de calculo, Pc, sobre la pala 1:
c
      if(ncapa.eq.2) pcx(npa,2) = pcx(npa,1)+ vnx(npa)*distan/4.d0
      if(ncapa.eq.2) pcy(npa,2) = pcy(npa,1)+ vny(npa)*distan/4.d0
      if(ncapa.eq.2) pcz(npa,2) = pcz(npa,1)+ vnz(npa)*distan/4.d0
c
      if(ncapa.eq.3) pcx(npa,3) = pcx(npa,1)+ vnx(npa)*distan/2.d0
      if(ncapa.eq.3) pcy(npa,3) = pcy(npa,1)+ vny(npa)*distan/2.d0
      if(ncapa.eq.3) pcz(npa,3) = pcz(npa,1)+ vnz(npa)*distan/2.d0
c
      if(ncapa.eq.4) pcx(npa,4) = pcx(npa,1)+ 3.*vnx(npa)*distan/4.d0
      if(ncapa.eq.4) pcy(npa,4) = pcy(npa,1)+ 3.*vny(npa)*distan/4.d0
      if(ncapa.eq.4) pcz(npa,4) = pcz(npa,1)+ 3.*vnz(npa)*distan/4.d0
c
      if(ncapa.eq.5) pcx(npa,5) = pcx(npa,1)+ vnx(npa)*distan
      if(ncapa.eq.5) pcy(npa,5) = pcy(npa,1)+ vny(npa)*distan
      if(ncapa.eq.5) pcz(npa,5) = pcz(npa,1)+ vnz(npa)*distan
c
      if(ncapa.eq.6) pcx(npa,6) = pcx(npa,1)- vnx(npa)*distan/4.d0
      if(ncapa.eq.6) pcy(npa,6) = pcy(npa,1)- vny(npa)*distan/4.d0
      if(ncapa.eq.6) pcz(npa,6) = pcz(npa,1)- vnz(npa)*distan/4.d0
c
      if(ncapa.eq.7) pcx(npa,7) = pcx(npa,1)- vnx(npa)*distan/2.d0
      if(ncapa.eq.7) pcy(npa,7) = pcy(npa,1)- vny(npa)*distan/2.d0
      if(ncapa.eq.7) pcz(npa,7) = pcz(npa,1)- vnz(npa)*distan/2.d0
c
      if(ncapa.eq.8) pcx(npa,8) = pcx(npa,1)- 3.*vnx(npa)*distan/4.d0
      if(ncapa.eq.8) pcy(npa,8) = pcy(npa,1)- 3.*vny(npa)*distan/4.d0
      if(ncapa.eq.8) pcz(npa,8) = pcz(npa,1)- 3.*vnz(npa)*distan/4.d0
c
      if(ncapa.eq.9) pcx(npa,9) = pcx(npa,1)- vnx(npa)*distan
      if(ncapa.eq.9) pcy(npa,9) = pcy(npa,1)- vny(npa)*distan
      if(ncapa.eq.9) pcz(npa,9) = pcz(npa,1)- vnz(npa)*distan
c
   16 continue
   15 continue
c   
      return
      end
c
c-----------------------------------------------------------------------
c
      subroutine puntos2
c                     
c    TERCERA PARTE (a):  
c  
c    Puntos de colocacion para condicion de contorno anterior 
c
c    coordenadas del punto de colocacion (ncapa = 2) 
c
c.......................................................................
c>
      implicit real*8 (a-h,o-z)
c
      parameter (maxir=51,maxio=51,maxip=11,maxnk=2001,
     &          mxir=maxir-1,mxio=maxio-1,mxip=maxip-1,
     &          maxro=maxir*maxio,mxro=mxir*mxio,mxnk=maxnk-1)
c
      common r(maxir),o(maxio),chord(maxir),yarc(maxir,maxio)
      common px(maxro),py(maxro),pz(maxro)
      common xbf(maxir),ybf(maxir),zbf(maxir),rbf(maxir)
      common xe(maxir,maxnk),ye(maxir,maxnk),ze(maxir,maxnk),
     &       re(maxir,maxnk),fi(maxir,maxnk),fifa(mxro,5),fipri(mxro,5)
c     
      common p1x(mxro),p1y(mxro),p1z(mxro),      
     &       p2x(mxro),p2y(mxro),p2z(mxro),
     &       p3x(mxro),p3y(mxro),p3z(mxro),
     &       p4x(mxro),p4y(mxro),p4z(mxro),
     &       pax(mxro),pay(mxro),paz(mxro),
     &       pbx(mxro),pby(mxro),pbz(mxro)
c
      common pcx(mxro,maxip),pcy(mxro,maxip),pcz(mxro,maxip),
     &       area(mxro),ss1(mxro,maxip),ss2(mxro,maxip),
     &       vnx(mxro),vny(mxro),vnz(mxro),Vinf(mxro)
c
      common gamma(mxro),circ(maxro),carga(mxro),theta(1)  
      common ciex(mxro,maxir),ciey(mxro,maxir),ciez(mxro,maxir),
     &       cix1tmp(mxro*mxro),ciy1tmp(mxro*mxro),ciz1tmp(mxro*mxro),
     &       cix2tmp(mxro*mxro),ciy2tmp(mxro*mxro),ciz2tmp(mxro*mxro)
      common vix(mxro,maxip),viy(mxro,maxip),viz(mxro,maxip),
     &       vi(mxro,maxip),vtgx(mxro,maxip),vtgy(mxro,maxip),
     &       urx(mxro,maxip),ury(mxro,maxip),urz(mxro,maxip)     
      common urex(mxro),urey(mxro),urez(mxro),
     &       urix(mxro),uriy(mxro),uriz(mxro)
c
      common U,UU,omega,c0,a,rh,rt,oi,of,pf,ch,ct,zlim,factor1,factor2
      common pi,beta,cero,signo,redvel,coefa,hc,dfi,alfac,c1,c2,distan
      common indice,index0,index1,index2,index3,index4,index5,index6,      
     &       index7,index8,index9,index10,index11,index12,alfac0      
      common npan,nodos,ncapa,npal,npaso,nr,no,np,nk,kult,inic,in1,in2, 
     &       in3,nsubr,nsld2
c
      character integ1(maxro)*150,integ2(maxro)*150,gamastr(maxro)*70,
     &          circostr(maxro)*70,salida2out(102)*95
c     Variable para internal file del archivo global subr.out
c     el cual lleva los mismos datos que la salida standar
      character subrout(500)*60
c                      
                      
      common integ1,integ2,gamastr,circostr,subrout,salida2out
c
c<
c.......................................................................
c
      ncapa = 2
c                   
      bet0   = beta-1.
      bet1   = beta+1.
      relbet = bet1/bet0
c
      do 15 io=1,no
c
      if(index8.eq.0) ybeta = (io*1.)/no    
      if(index8.eq.0) goto 17    
c     
      valor0= 1.-(io*1.)/no 
      valor1= relbet**valor0
      ybeta = (bet1-bet0*valor1)/(valor1+1.)
c      
   17 continue    
c
      do 16 ir=1,nr
c
      ndiv = ir+(io-1)*nr
c
      x01 = (r(ir)+r(ir+1))/2.      
      if(index9.eq.0) psirmed=datan(a/x01)   
      if(index9.ne.0) psirmed=datan(UU/(omega*x01))-alfac*r(ir)/rt   
     &                                             -alfac0
      fifa(ndiv,ncapa) = psirmed  
      senpsi=dsin(psirmed)
      cospsi=dcos(psirmed)         
c                      
      ainv = omega/UU  
      ax12 = (ainv*x01)**2
      psiprima = (-1.)*ainv/(1.+ax12)
      fipri(ndiv,ncapa) = psiprima  
c
ccc      x1(ir,io,ip)= r(ir) 
ccc      y1(ir,io,ip)= chord(ir)*o(io)*cospsi-perp*senpsi
ccc      z1(ir,io,ip)= chord(ir)*o(io)*senpsi+perp*cospsi  
c
c     x02 = 0           f(x1,x2) = C1   para todo x01
c 
      pcx(ndiv,ncapa)=  x01               
      pcy(ndiv,ncapa)= -ybeta*C1*senpsi 
      pcz(ndiv,ncapa)=  ybeta*C1*cospsi 
c                                             
   16 continue
   15 continue
c   
      return
      end
c
c-----------------------------------------------------------------------
c
      subroutine puntos3
c                     
c    TERCERA PARTE (b):  
c  
c    Puntos de colocacion para condicion de contorno superior 
c
c    coordenadas del punto de colocacion (ncapa = 3) 
c
c.......................................................................
c>
      implicit real*8 (a-h,o-z)
c
      parameter (maxir=51,maxio=51,maxip=11,maxnk=2001,
     &          mxir=maxir-1,mxio=maxio-1,mxip=maxip-1,
     &          maxro=maxir*maxio,mxro=mxir*mxio,mxnk=maxnk-1)
c
      common r(maxir),o(maxio),chord(maxir),yarc(maxir,maxio)
      common px(maxro),py(maxro),pz(maxro)
      common xbf(maxir),ybf(maxir),zbf(maxir),rbf(maxir)
      common xe(maxir,maxnk),ye(maxir,maxnk),ze(maxir,maxnk),
     &       re(maxir,maxnk),fi(maxir,maxnk),fifa(mxro,5),fipri(mxro,5)
c     
      common p1x(mxro),p1y(mxro),p1z(mxro),      
     &       p2x(mxro),p2y(mxro),p2z(mxro),
     &       p3x(mxro),p3y(mxro),p3z(mxro),
     &       p4x(mxro),p4y(mxro),p4z(mxro),
     &       pax(mxro),pay(mxro),paz(mxro),
     &       pbx(mxro),pby(mxro),pbz(mxro)
c
      common pcx(mxro,maxip),pcy(mxro,maxip),pcz(mxro,maxip),
     &       area(mxro),ss1(mxro,maxip),ss2(mxro,maxip),
     &       vnx(mxro),vny(mxro),vnz(mxro),Vinf(mxro)
c
      common gamma(mxro),circ(maxro),carga(mxro),theta(1)  
      common ciex(mxro,maxir),ciey(mxro,maxir),ciez(mxro,maxir),
     &       cix1tmp(mxro*mxro),ciy1tmp(mxro*mxro),ciz1tmp(mxro*mxro),
     &       cix2tmp(mxro*mxro),ciy2tmp(mxro*mxro),ciz2tmp(mxro*mxro)
      common vix(mxro,maxip),viy(mxro,maxip),viz(mxro,maxip),
     &       vi(mxro,maxip),vtgx(mxro,maxip),vtgy(mxro,maxip),
     &       urx(mxro,maxip),ury(mxro,maxip),urz(mxro,maxip)     
      common urex(mxro),urey(mxro),urez(mxro),
     &       urix(mxro),uriy(mxro),uriz(mxro)
c
      common U,UU,omega,c0,a,rh,rt,oi,of,pf,ch,ct,zlim,factor1,factor2
      common pi,beta,cero,signo,redvel,coefa,hc,dfi,alfac,c1,c2,distan
      common indice,index0,index1,index2,index3,index4,index5,index6,      
     &       index7,index8,index9,index10,index11,index12,alfac0      
      common npan,nodos,ncapa,npal,npaso,nr,no,np,nk,kult,inic,in1,in2, 
     &       in3,nsubr,nsld2
c
      character integ1(maxro)*150,integ2(maxro)*150,gamastr(maxro)*70,
     &          circostr(maxro)*70,salida2out(102)*95
c     Variable para internal file del archivo global subr.out
c     el cual lleva los mismos datos que la salida standar
      character subrout(500)*60
c                      
                      
      common integ1,integ2,gamastr,circostr,subrout,salida2out
c
c<
c.......................................................................
c
      ncapa = 3
c        
      do 15 io=1,no
      do 16 ir=1,nr
c
      ndiv=ir+(io-1)*nr
c
      x01 = (r(ir)+r(ir+1))/2.      
      if(index9.eq.0) psirmed=datan(a/x01)   
      if(index9.ne.0) psirmed=datan(UU/(omega*x01))-alfac*r(ir)/rt 
     &                                             -alfac0
      fifa(ndiv,ncapa) = psirmed  
      senpsi=dsin(psirmed)
      cospsi=dcos(psirmed)            
c                      
      ainv = omega/UU  
      ax12 = (ainv*x01)**2
      psiprima = (-1.)*ainv/(1.+ax12)
      fipri(ndiv,ncapa) = psiprima  
c                       
      if(index10.ne.0) cprop = o(io)
      if(index10.eq.0) cprop = 1.*io/no
c
c     x03 = f(x1,x2) = C1 + C2~*SQRT(x02)/g(x01)
c                
      x02 = chord(ir)*cprop  
      x03 = C1 + C2*dsqrt(x02)/((1.+(omega*x01/UU)**2)**0.25)
c
      radicha2 = 1.+(x02*psiprima)**2
      radicha  = dsqrt(radicha2)       
c
      pcx(ndiv,ncapa)= x01 - x03*x02*psiprima/radicha
      pcy(ndiv,ncapa)= x02*cospsi - x03*senpsi/radicha
      pcz(ndiv,ncapa)= x02*senpsi + x03*cospsi/radicha
c                                             
   16 continue
   15 continue
c   
      return
      end
c
c-----------------------------------------------------------------------
c
      subroutine puntos45
c                     
c    TERCERA PARTE (b):  
c  
c    Puntos de colocacion para las condiciones de contorno laterales 
c
c    coordenadas del punto de colocacion (ncapa = 4 [int] y 5 [ext]) 
c
c.......................................................................
c>
      implicit real*8 (a-h,o-z)
c
      parameter (maxir=51,maxio=51,maxip=11,maxnk=2001,
     &          mxir=maxir-1,mxio=maxio-1,mxip=maxip-1,
     &          maxro=maxir*maxio,mxro=mxir*mxio,mxnk=maxnk-1)
c
      common r(maxir),o(maxio),chord(maxir),yarc(maxir,maxio)
      common px(maxro),py(maxro),pz(maxro)
      common xbf(maxir),ybf(maxir),zbf(maxir),rbf(maxir)
      common xe(maxir,maxnk),ye(maxir,maxnk),ze(maxir,maxnk),
     &       re(maxir,maxnk),fi(maxir,maxnk),fifa(mxro,5),fipri(mxro,5)
c     
      common p1x(mxro),p1y(mxro),p1z(mxro),      
     &       p2x(mxro),p2y(mxro),p2z(mxro),
     &       p3x(mxro),p3y(mxro),p3z(mxro),
     &       p4x(mxro),p4y(mxro),p4z(mxro),
     &       pax(mxro),pay(mxro),paz(mxro),
     &       pbx(mxro),pby(mxro),pbz(mxro)
c
      common pcx(mxro,maxip),pcy(mxro,maxip),pcz(mxro,maxip),
     &       area(mxro),ss1(mxro,maxip),ss2(mxro,maxip),
     &       vnx(mxro),vny(mxro),vnz(mxro),Vinf(mxro)
c
      common gamma(mxro),circ(maxro),carga(mxro),theta(1)  
      common ciex(mxro,maxir),ciey(mxro,maxir),ciez(mxro,maxir),
     &       cix1tmp(mxro*mxro),ciy1tmp(mxro*mxro),ciz1tmp(mxro*mxro),
     &       cix2tmp(mxro*mxro),ciy2tmp(mxro*mxro),ciz2tmp(mxro*mxro)
      common vix(mxro,maxip),viy(mxro,maxip),viz(mxro,maxip),
     &       vi(mxro,maxip),vtgx(mxro,maxip),vtgy(mxro,maxip),
     &       urx(mxro,maxip),ury(mxro,maxip),urz(mxro,maxip)     
      common urex(mxro),urey(mxro),urez(mxro),
     &       urix(mxro),uriy(mxro),uriz(mxro)
c
      common U,UU,omega,c0,a,rh,rt,oi,of,pf,ch,ct,zlim,factor1,factor2
      common pi,beta,cero,signo,redvel,coefa,hc,dfi,alfac,c1,c2,distan
      common indice,index0,index1,index2,index3,index4,index5,index6,      
     &       index7,index8,index9,index10,index11,index12,alfac0      
      common npan,nodos,ncapa,npal,npaso,nr,no,np,nk,kult,inic,in1,in2, 
     &       in3,nsubr,nsld2
c
      character integ1(maxro)*150,integ2(maxro)*150,gamastr(maxro)*70,
     &          circostr(maxro)*70,salida2out(102)*95
c     Variable para internal file del archivo global subr.out
c     el cual lleva los mismos datos que la salida standar
      character subrout(500)*60
c                      
                      
      common integ1,integ2,gamastr,circostr,subrout,salida2out
c
c<
c.......................................................................
c
      if(ncapa.eq.4) x01 = r(1)-(r(2)-r(1))/nr
      if(ncapa.eq.5) x01 = r(nr+1)+(r(nr+1)-r(nr))/nr
c
      if(ncapa.eq.4) cuerda = chord(1)
      if(ncapa.eq.5) cuerda = chord(nr+1)
c
      if(index9.eq.0) psirmed=datan(a/x01)   
      if(index9.ne.0) psirmed=datan(UU/(omega*x01))-alfac*r(ir)/rt   
     &                                             -alfac0
      senpsi=dsin(psirmed)
      cospsi=dcos(psirmed)         
c                      
      ainv = omega/UU  
      ax12 = (ainv*x01)**2
      psiprima = (-1.)*ainv/(1+ax12)
c                   
      bet0   = beta-1.
      bet1   = beta+1.
      relbet = bet1/bet0
c
      do 15 io=1,no
c                       
      if(index10.ne.0) cprop = o(io)
      if(index10.eq.0) cprop = 1.*(io-1)/no
c
      do 16 ir=1,nr
c
      if(index8.eq.0) ybeta = (ir*1.)/nr    
      if(index8.eq.0) goto 17    
c     
      valor0= 1.-(ir*1.)/nr 
      valor1= relbet**valor0
      ybeta = (bet1-bet0*valor1)/(valor1+1.)
c      
   17 continue    
c
      ndiv=ir+(io-1)*nr
      fifa(ndiv,ncapa) = psirmed  
      fipri(ndiv,ncapa) = psiprima  
c
c     x03 = f(x1,x2) = C1 + C2~*SQRT(x02)/g(x01)
c                
      x02 = chord(ir)*cprop  
      x03 = C1 + C2*dsqrt(x02)/((1.+(omega*x01/UU)**2)**0.25)
c
      radicha2 = 1.+(x02*psiprima)**2
      radicha  = dsqrt(radicha2)       
c
      pcx(ndiv,ncapa)= x01 - ybeta*x03*x02*psiprima/radicha
      pcy(ndiv,ncapa)= x02*cospsi - ybeta*x03*senpsi/radicha
      pcz(ndiv,ncapa)= x02*senpsi + ybeta*x03*cospsi/radicha
c                                             
   16 continue
   15 continue
c   
      return
      end
c
c-----------------------------------------------------------------------
c
      subroutine anillo(outstd,tam)  
c                                 
c.......................................................................
c>
      implicit real*8 (a-h,o-z)
c
      parameter (maxir=51,maxio=51,maxip=11,maxnk=2001,
     &          mxir=maxir-1,mxio=maxio-1,mxip=maxip-1,
     &          maxro=maxir*maxio,mxro=mxir*mxio,mxnk=maxnk-1)
c
      common r(maxir),o(maxio),chord(maxir),yarc(maxir,maxio)
      common px(maxro),py(maxro),pz(maxro)
      common xbf(maxir),ybf(maxir),zbf(maxir),rbf(maxir)
      common xe(maxir,maxnk),ye(maxir,maxnk),ze(maxir,maxnk),
     &       re(maxir,maxnk),fi(maxir,maxnk),fifa(mxro,5),fipri(mxro,5)
c     
      common p1x(mxro),p1y(mxro),p1z(mxro),      
     &       p2x(mxro),p2y(mxro),p2z(mxro),
     &       p3x(mxro),p3y(mxro),p3z(mxro),
     &       p4x(mxro),p4y(mxro),p4z(mxro),
     &       pax(mxro),pay(mxro),paz(mxro),
     &       pbx(mxro),pby(mxro),pbz(mxro)
c
      common pcx(mxro,maxip),pcy(mxro,maxip),pcz(mxro,maxip),
     &       area(mxro),ss1(mxro,maxip),ss2(mxro,maxip),
     &       vnx(mxro),vny(mxro),vnz(mxro),Vinf(mxro)
c
      common gamma(mxro),circ(maxro),carga(mxro),theta(1)  
      common ciex(mxro,maxir),ciey(mxro,maxir),ciez(mxro,maxir),
     &       cix1tmp(mxro*mxro),ciy1tmp(mxro*mxro),ciz1tmp(mxro*mxro),
     &       cix2tmp(mxro*mxro),ciy2tmp(mxro*mxro),ciz2tmp(mxro*mxro)
      common vix(mxro,maxip),viy(mxro,maxip),viz(mxro,maxip),
     &       vi(mxro,maxip),vtgx(mxro,maxip),vtgy(mxro,maxip),
     &       urx(mxro,maxip),ury(mxro,maxip),urz(mxro,maxip)     
      common urex(mxro),urey(mxro),urez(mxro),
     &       urix(mxro),uriy(mxro),uriz(mxro)
c
      common U,UU,omega,c0,a,rh,rt,oi,of,pf,ch,ct,zlim,factor1,factor2
      common pi,beta,cero,signo,redvel,coefa,hc,dfi,alfac,c1,c2,distan
      common indice,index0,index1,index2,index3,index4,index5,index6,      
     &       index7,index8,index9,index10,index11,index12,alfac0      
      common npan,nodos,ncapa,npal,npaso,nr,no,np,nk,kult,inic,in1,in2, 
     &       in3,nsubr,nsld2
c
      character integ1(maxro)*150,integ2(maxro)*150,gamastr(maxro)*70,
     &          circostr(maxro)*70,salida2out(102)*95
c     Variable para internal file del archivo global subr.out
c     el cual lleva los mismos datos que la salida standar
      character subrout(500)*60
c                      
                      
      common integ1,integ2,gamastr,circostr,subrout,salida2out
c
c<
      integer tam
      character outstd(50)*100
!  OUTSTD es un array de caracteres para llevar la salida estandar de la 
!  subrutina, en lugar de hacer write(6). Se difiere su escritura en 
!  pantalla hasta volver al programa Main. 
!  TAM lleva la cantidad de posiciones utilizadas en OUTSTD
!  Ambas variables van por parametro en el nombre de la subrutina.
c.......................................................................
c
      dimension cix(mxro,mxro),ciy(mxro,mxro),ciz(mxro,mxro)
c     
c.......................................................................
c                              
      tam=0
c
      print*,"en anillo"
      write(salida2out(nsld2),21)indice,ncapa     
      write(salida2out(nsld2+1),'(a1)') ""
      nsld2=nsld2+2
   21 format(2x,'Indice:',i2,9x,'Capa No.',i3)
!      write(50,21)indice,ncapa     
!   21 format(2x,'Indice:',i2,9x,'Capa No.',i3,/)
c
c                                               
      do 10 npa=1,npan
      do 20 nv=1,npan
CCC      do 30 ib=1,npal 
      ib=1
c                  
      cix(npa,nv)= cero
      ciy(npa,nv)= cero
      ciz(npa,nv)= cero
c                     
   30 continue
   20 continue
   10 continue     
c                 
c     nav: numero de anillos vorticosos
c                  
      nav=npan-nr
c   
      do 1 npa=1,npan
c      
      xc=pcx(npa,ncapa)
      yc=pcy(npa,ncapa)
      zc=pcz(npa,ncapa)
c
CCC      do 9 ib=1,npal 
      ib=1 
c      
      if(npa.eq.npan) write(subrout(nsubr),13)npa,ib,npal
      if(npa.eq.npan) nsubr=nsubr+1
!      write(15,13)npa,ib,npal
      !if(npa.eq.npan) write(6,13) npa,ib,npal
      if(npa.eq.npan) tam=1
      if(npa.eq.npan) write(outstd(tam),13) npa,ib,npal
      if(npa.eq.npan) write(outstd(tam+1),31) 
      if(npa.eq.npan) tam=tam+2
!  BORRADOS CARACTERES ,/  DEL FINAL DEL FORMAT
   13 format(3x,'panel No.',i4,4x,'pala',i3,' de',i3) 
ccc      if(ib.eq.npal) write(subrout(nsubr),31)  
!      write(15,31)  
ccc      if(ib.eq.npal) write(6,31) 
   31 format(2x)    
c      
      do 2 nv=1,npan         
c
      if(nv.gt.nav)goto 3
c
c     ANILLOS VORTICOSOS COMPLETOS
c
c     tramo ab
c
      xa=pax(nv)
      ya=pay(nv)
      za=paz(nv)
c             
      xb=pbx(nv)
      yb=pby(nv)
      zb=pbz(nv)            
c
      call segmento(xc,yc,zc,xa,ya,za,xb,yb,zb,cicx,cicy,cicz)  
c                  
      cix(npa,nv)=cix(npa,nv)+cicx
      ciy(npa,nv)=ciy(npa,nv)+cicy
      ciz(npa,nv)=ciz(npa,nv)+cicz
c
c     tramo bb'
c
      xa=pbx(nv)
      ya=pby(nv)
      za=pbz(nv)
c             
      xb=pbx(nv+nr)
      yb=pby(nv+nr)
      zb=pbz(nv+nr)            
c
      call segmento(xc,yc,zc,xa,ya,za,xb,yb,zb,cicx,cicy,cicz)  
c                  
      cix(npa,nv)=cix(npa,nv)+cicx
      ciy(npa,nv)=ciy(npa,nv)+cicy
      ciz(npa,nv)=ciz(npa,nv)+cicz
c
c     tramo b'a'
c
      xa=pbx(nv+nr)
      ya=pby(nv+nr)
      za=pbz(nv+nr)
c             
      xb=pax(nv+nr)
      yb=pay(nv+nr)
      zb=paz(nv+nr)            
c
      call segmento(xc,yc,zc,xa,ya,za,xb,yb,zb,cicx,cicy,cicz)  
c                  
      cix(npa,nv)=cix(npa,nv)+cicx
      ciy(npa,nv)=ciy(npa,nv)+cicy
      ciz(npa,nv)=ciz(npa,nv)+cicz
c
c     tramo a'a
c
      xa=pax(nv+nr)
      ya=pay(nv+nr)
      za=paz(nv+nr)
c             
      xb=pax(nv)
      yb=pay(nv)
      zb=paz(nv)            
c
      call segmento(xc,yc,zc,xa,ya,za,xb,yb,zb,cicx,cicy,cicz)  
c                  
      cix(npa,nv)=cix(npa,nv)+cicx
      ciy(npa,nv)=ciy(npa,nv)+cicy
      ciz(npa,nv)=ciz(npa,nv)+cicz
c
      goto 4      
c--------------- BF      
   3  continue
c
c     SEGMENTOS VORTICOSOS DE LOS PANELES DE BORDE DE FUGA
c
c     tramo ab(BF)
c
      xa=pax(nv)
      ya=pay(nv)
      za=paz(nv)
c             
      xb=pbx(nv)
      yb=pby(nv)
      zb=pbz(nv)            
c
      call segmento(xc,yc,zc,xa,ya,za,xb,yb,zb,cicx,cicy,cicz)  
c                  
      cix(npa,nv)=cix(npa,nv)+cicx
      ciy(npa,nv)=ciy(npa,nv)+cicy
      ciz(npa,nv)=ciz(npa,nv)+cicz
c
c     tramo bb'(BF)
c
      xa=pbx(nv)
      ya=pby(nv)
      za=pbz(nv)
c             
      xb=p3x(nv)
      yb=p3y(nv)
      zb=p3z(nv)            
c
      call segmento(xc,yc,zc,xa,ya,za,xb,yb,zb,cicx,cicy,cicz)  
c                  
      cix(npa,nv)=cix(npa,nv)+cicx
      ciy(npa,nv)=ciy(npa,nv)+cicy
      ciz(npa,nv)=ciz(npa,nv)+cicz
c
c     tramo a'a(BF)
c
      xa=p4x(nv)
      ya=p4y(nv)
      za=p4z(nv)
c             
      xb=pax(nv)
      yb=pay(nv)
      zb=paz(nv)            
c
      call segmento(xc,yc,zc,xa,ya,za,xb,yb,zb,cicx,cicy,cicz)  
c                  
      cix(npa,nv)=cix(npa,nv)+cicx
      ciy(npa,nv)=ciy(npa,nv)+cicy
      ciz(npa,nv)=ciz(npa,nv)+cicz
c            
c--------------- BF     
   4  continue   
c                         
   2  continue       
   9  continue
   1  continue
c
c.......................................................................
c     
!      print*,'ANILLO ',cix(1,1)
!      print*,'ANILLO 2 ',cix(npan,npan)
      kon=1
      do 114 npa=1,npan
      do 113 nv=1,npan
CCC      do 115 ib=1,npal  
      ib=1
c       
!      write(42)cix(npa,nv)
!      write(43)ciy(npa,nv)
!      write(44)ciz(npa,nv)                                     
      cix1tmp(kon)=cix(npa,nv)
      ciy1tmp(kon)=ciy(npa,nv)
      ciz1tmp(kon)=ciz(npa,nv)
      kon=kon+1
c
  115 continue
  113 continue    
  114 continue  
!      print*,'ANILLO 3 ',cix1tmp(1),' ',cix1tmp(npan*npan)
c                
!      rewind(42)
!      rewind(43)
!      rewind(44)
c
      return
      end
c
c-----------------------------------------------------------------------
c
      subroutine segmento(xc,yc,zc,xa,ya,za,xb,yb,zb,cicx,cicy,cicz)
c
      implicit real*8 (a-h,o-z)
c               
      uno=   1.0d0
      pi=    4.0d0*datan(uno)
      cero = 0.0d0
c                          
      r1x= xa-xc
      r1y= ya-yc
      r1z= za-zc
c                                         
      r2x= xb-xc
      r2y= yb-yc
      r2z= zb-zc
c                                         
      r0x= r2x-r1x
      r0y= r2y-r1y
      r0z= r2z-r1z
c
      r12= r1x**2+r1y**2+r1z**2
      r22= r2x**2+r2y**2+r2z**2
c
      r1= dsqrt(r12)
      r2= dsqrt(r22)
c            
      r1xr2x= (ya-yc)*(zb-zc)-(za-zc)*(yb-yc)
      r1xr2y= (za-zc)*(xb-xc)-(xa-xc)*(zb-zc)
      r1xr2z= (xa-xc)*(yb-yc)-(ya-yc)*(xb-xc)
c
      r1xr22= r1xr2x**2 + r1xr2y**2 + r1xr2z**2 
      r1xr2 = dsqrt(r1xr22)
c
      zero = 0.0000001d0
      if(r1.lt.zero.or.r2.lt.zero.or.r1xr2.lt.zero) goto 9

      r0r1= r0x*r1x + r0y*r1y + r0z*r1z
      r0r2= r0x*r2x + r0y*r2y + r0z*r2z
c                            
      den=4.*pi*r1xr22
      cte0=(r0r1/r1 - r0r2/r2)/den    
c          
      cicx=cte0*r1xr2x
      cicy=cte0*r1xr2y
      cicz=cte0*r1xr2z                                     
c
      goto 8
    9 continue
      cicx= cero
      cicy= cero
      cicz= cero                                   
    8 continue
c
      return
      end
c
c---------------------------------------------------------------------
c
      subroutine geomest(outstd,tam)
c
c     Geometria de la estela de hilos vorticosos helicoidales de paso cte y
c     radio variables si z < 5R
c     El calculo del radio local del hilo vorticoso helicoidal es realizado
c     por la FUNCTION radloc
c          
c.......................................................................
c>
      implicit real*8 (a-h,o-z)
c
      parameter (maxir=51,maxio=51,maxip=11,maxnk=2001,
     &          mxir=maxir-1,mxio=maxio-1,mxip=maxip-1,
     &          maxro=maxir*maxio,mxro=mxir*mxio,mxnk=maxnk-1)
c
      common r(maxir),o(maxio),chord(maxir),yarc(maxir,maxio)
      common px(maxro),py(maxro),pz(maxro)
      common xbf(maxir),ybf(maxir),zbf(maxir),rbf(maxir)
      common xe(maxir,maxnk),ye(maxir,maxnk),ze(maxir,maxnk),
     &       re(maxir,maxnk),fi(maxir,maxnk),fifa(mxro,5),fipri(mxro,5)
c     
      common p1x(mxro),p1y(mxro),p1z(mxro),      
     &       p2x(mxro),p2y(mxro),p2z(mxro),
     &       p3x(mxro),p3y(mxro),p3z(mxro),
     &       p4x(mxro),p4y(mxro),p4z(mxro),
     &       pax(mxro),pay(mxro),paz(mxro),
     &       pbx(mxro),pby(mxro),pbz(mxro)
c
      common pcx(mxro,maxip),pcy(mxro,maxip),pcz(mxro,maxip),
     &       area(mxro),ss1(mxro,maxip),ss2(mxro,maxip),
     &       vnx(mxro),vny(mxro),vnz(mxro),Vinf(mxro)
c
      common gamma(mxro),circ(maxro),carga(mxro),theta(1)  
      common ciex(mxro,maxir),ciey(mxro,maxir),ciez(mxro,maxir),
     &       cix1tmp(mxro*mxro),ciy1tmp(mxro*mxro),ciz1tmp(mxro*mxro),
     &       cix2tmp(mxro*mxro),ciy2tmp(mxro*mxro),ciz2tmp(mxro*mxro)
      common vix(mxro,maxip),viy(mxro,maxip),viz(mxro,maxip),
     &       vi(mxro,maxip),vtgx(mxro,maxip),vtgy(mxro,maxip),
     &       urx(mxro,maxip),ury(mxro,maxip),urz(mxro,maxip)     
      common urex(mxro),urey(mxro),urez(mxro),
     &       urix(mxro),uriy(mxro),uriz(mxro)
c
      common U,UU,omega,c0,a,rh,rt,oi,of,pf,ch,ct,zlim,factor1,factor2
      common pi,beta,cero,signo,redvel,coefa,hc,dfi,alfac,c1,c2,distan
      common indice,index0,index1,index2,index3,index4,index5,index6,      
     &       index7,index8,index9,index10,index11,index12,alfac0      
      common npan,nodos,ncapa,npal,npaso,nr,no,np,nk,kult,inic,in1,in2, 
     &       in3,nsubr,nsld2
c
      character integ1(maxro)*150,integ2(maxro)*150,gamastr(maxro)*70,
     &          circostr(maxro)*70,salida2out(102)*95
c     Variable para internal file del archivo global subr.out
c     el cual lleva los mismos datos que la salida standar
      character subrout(500)*60
c                      
                      
      common integ1,integ2,gamastr,circostr,subrout,salida2out
c
      integer tam
      character outstd(50)*100
!  OUTSTD es un array de caracteres para llevar la salida estandar de la 
!  subrutina, en lugar de hacer write(6). Se difiere su escritura en 
!  pantalla hasta volver al programa Main. 
!  TAM lleva la cantidad de posiciones utilizadas en OUTSTD
!  Ambas variables van por parametro en el nombre de la subrutina.
c<
c.......................................................................
c                   
      dimension fi0(maxir)
c                
c.......................................................................
c                   
      tam=1
c
      zult1=factor1*rt
      zult2=factor2*rt 
      fiult=zult2/c0
      dfi=fiult/nk 
!      write(6,*)factor1,factor2,fiult,fiult/(2.*pi)
      write(outstd(tam),443)factor1,factor2,fiult,fiult/(2.*pi)
  443 format(3x,f18.15,8x,f18.15,8x,f18.14,8x,f18.15)
c  443 format('(a100)')
      tam=tam+1
c                    
CCC      do 9 ib=1,npal
      ib=1
c      
      do 2 ir=1,nr+1
      ratio= ybf(ir)/xbf(ir)
      fi0(ir)= datan(ratio)  
c       
      do 3 ik=1,kult                   
c
      if(ib.gt.1)goto 10
c
      fi(ir,ik)=fi0(ir)+dfi*(ik-1)
c
c    inicio de la estela (k=1) & fi = fi0, coincidente con BF del panel
c                                   
      if(ik.gt.1) goto 66
      xe(ir,1)=xbf(ir)
      ye(ir,1)=ybf(ir)
      ze(ir,1)=zbf(ir)
      re(ir,1)=rbf(ir) 
      goto 77
   66 continue       
c                               
c    calculo del radio local de los tubos de corriente envolventes
c
c    Re = F(Ze, Rbf, a)   determinado por la funcion RADLOC
c
      ze(ir,ik)=zbf(ir)+c0*(fi(ir,ik)-fi0(ir))
      if(ze(ir,ik).le.zult1) 
     &   re(ir,ik)=radloc(ze(ir,ik),rbf(ir),redvel)
      if(ze(ir,ik).gt.zult1) 
     &   re(ir,ik)=re(ir,ik-1)
      goto 99    
   10 continue    
c
      if(ik.gt.1) goto 11
      xe(ir,1)=rbf(ir)*dcos(fi(ir,ik)+theta(ib))
      ye(ir,1)=rbf(ir)*dsin(fi(ir,ik)+theta(ib)) 
      ze(ir,1)=zbf(ir)
      goto 88  
   11 continue
c           
   99 continue
      xe(ir,ik)=re(ir,ik)*dcos(fi(ir,ik)+theta(ib))
      ye(ir,ik)=re(ir,ik)*dsin(fi(ir,ik)+theta(ib)) 
      ze(ir,ik)=ze(ir,ik)    
   88 continue
   77 continue  
c                    
c     graficacion de 3 hilos de la estela, con coordenadas adimensionalizadas
c     con el Radio de la pala
c
      if(ir.ne.1) goto 4 
      if(ze(ir,ik).le.zlim)    
     &write(14,5) xe(ir,ik)/rt,ye(ir,ik)/rt,ze(ir,ik)/rt,
     &            re(ir,ik)/rbf(ir),re(ir,ik)/rt
    4 continue  
c     
      if(ir.ne.(nr+1)/2) goto 1     
      if(ze(ir,ik).le.zlim)    
     &write(17,5) xe(ir,ik)/rt,ye(ir,ik)/rt,ze(ir,ik)/rt,
     &            re(ir,ik)/rbf(ir),re(ir,ik)/rt
    1 continue 
c    
      if(ir.ne.(nr+1)) goto 6     
      if(ze(ir,ik).le.zlim)    
     &write(18,5) xe(ir,ik)/rt,ye(ir,ik)/rt,ze(ir,ik)/rt,
     &            re(ir,ik)/rbf(ir),re(ir,ik)/rt
    6 continue
    5 format(2x,5(f11.6,1x)) 
c                      
    3 continue      
    2 continue   
    9 continue               
c                            
CRAP  goto 345
c
c     graficacion p/TECPLOT
c
      number=2*nr    
c
      do 8 ir=1,nr+1
      write(8,201) 
  201 format(1x,/1x,'GEOMETRY X = 0, Y = 0, Z = 0, T=LINE3D, F=POINT')
c
      write(8,202)
  202 format(1x,'1')
c
      write(8,203)number
  203 format(1x,i3)
c     
      do 7 ik=1,number
      write(8,204) xe(ir,ik),ye(ir,ik),ze(ir,ik)
  204 format(1x,3(f11.6,1x))
c                 
    7 continue
    8 continue
c             
  345 continue
c         
      return
      end
c
c---------------------------------------------------------------------
c
      subroutine estela(outstd,tam)
c
c     Calculo de los coeficientes de influencia de los hilos libres  
c     ciex,ciey,ciez                                     
c
c     nhl: numero de hilos vorticosos libres   1 <= nhl <= (nr+1) 
c         
c.......................................................................
c>
      implicit real*8 (a-h,o-z)
c
      parameter (maxir=51,maxio=51,maxip=11,maxnk=2001,
     &          mxir=maxir-1,mxio=maxio-1,mxip=maxip-1,
     &          maxro=maxir*maxio,mxro=mxir*mxio,mxnk=maxnk-1)
c
      common r(maxir),o(maxio),chord(maxir),yarc(maxir,maxio)
      common px(maxro),py(maxro),pz(maxro)
      common xbf(maxir),ybf(maxir),zbf(maxir),rbf(maxir)
      common xe(maxir,maxnk),ye(maxir,maxnk),ze(maxir,maxnk),
     &       re(maxir,maxnk),fi(maxir,maxnk),fifa(mxro,5),fipri(mxro,5)
c     
      common p1x(mxro),p1y(mxro),p1z(mxro),      
     &       p2x(mxro),p2y(mxro),p2z(mxro),
     &       p3x(mxro),p3y(mxro),p3z(mxro),
     &       p4x(mxro),p4y(mxro),p4z(mxro),
     &       pax(mxro),pay(mxro),paz(mxro),
     &       pbx(mxro),pby(mxro),pbz(mxro)
c
      common pcx(mxro,maxip),pcy(mxro,maxip),pcz(mxro,maxip),
     &       area(mxro),ss1(mxro,maxip),ss2(mxro,maxip),
     &       vnx(mxro),vny(mxro),vnz(mxro),Vinf(mxro)
c
      common gamma(mxro),circ(maxro),carga(mxro),theta(1)  
      common ciex(mxro,maxir),ciey(mxro,maxir),ciez(mxro,maxir),
     &       cix1tmp(mxro*mxro),ciy1tmp(mxro*mxro),ciz1tmp(mxro*mxro),
     &       cix2tmp(mxro*mxro),ciy2tmp(mxro*mxro),ciz2tmp(mxro*mxro)
      common vix(mxro,maxip),viy(mxro,maxip),viz(mxro,maxip),
     &       vi(mxro,maxip),vtgx(mxro,maxip),vtgy(mxro,maxip),
     &       urx(mxro,maxip),ury(mxro,maxip),urz(mxro,maxip)     
      common urex(mxro),urey(mxro),urez(mxro),
     &       urix(mxro),uriy(mxro),uriz(mxro)
c
      common U,UU,omega,c0,a,rh,rt,oi,of,pf,ch,ct,zlim,factor1,factor2
      common pi,beta,cero,signo,redvel,coefa,hc,dfi,alfac,c1,c2,distan
      common indice,index0,index1,index2,index3,index4,index5,index6,      
     &       index7,index8,index9,index10,index11,index12,alfac0      
      common npan,nodos,ncapa,npal,npaso,nr,no,np,nk,kult,inic,in1,in2, 
     &       in3,nsubr,nsld2
c
      character integ1(maxro)*150,integ2(maxro)*150,gamastr(maxro)*70,
     &          circostr(maxro)*70,salida2out(102)*95
c     Variable para internal file del archivo global subr.out
c     el cual lleva los mismos datos que la salida standar
      character subrout(500)*60
c                      
                      
      common integ1,integ2,gamastr,circostr,subrout,salida2out
c
c<
      integer tam
      integer p1,p2
      character outstd(50)*100
!  OUTSTD es un array de caracteres para llevar la salida estandar de la 
!  subrutina, en lugar de hacer write(6). Se difiere su escritura en 
!  pantalla hasta volver al programa Main. 
!  TAM lleva la cantidad de posiciones utilizadas en OUTSTD
!  Ambas variables van por parametro en el nombre de la subrutina.
c.......................................................................
c       
      dimension fx(maxnk),fy(maxnk),fz(maxnk),dista(maxnk),denom(maxnk)
c
c.......................................................................
c       
      tam=1
c
c!$OMP PARALLEL DO
      do 11 npa=1,npan
      do 12 ir=1,nr+1  
      nhl=ir
CCC      do 13 ib=1,npal 
      ib=1
c
      ciex(npa,nhl)= cero
      ciey(npa,nhl)= cero
      ciez(npa,nhl)= cero
c          
c   13 continue
   12 continue
   11 continue              
c!$OMP END PARALLEL DO
c          
      dfi3=dfi/3.
      ctte=4.*pi      
!      write(6,*)ctte      
      write(outstd(tam),*)ctte      
      tam=tam+1
c     
CCC      do 4 ib=1,npal
      ib=1
c        
      write(subrout(nsubr),'(a1)')"M"
      write(subrout(nsubr+1),34)ib,npal
      write(subrout(nsubr+2),35)dfi,dfi*180/pi
      nsubr=nsubr+3
!      write(15,33)ib,npal,dfi,dfi*180/pi
!      write(6,33) ib,npal,dfi,dfi*180/pi
      write(outstd(tam),'(a1)') ""
      write(outstd(tam+1),34) ib,npal
      write(outstd(tam+2),'(a1)') ""
      write(outstd(tam+3),35) dfi,dfi*180/pi
      tam=tam+4
!   33 format(1x,/,20x,'pala',i3,' de',i3,//,
!     &       2x,'Dfi =',f12.8,' rad  =',f8.4,' o')   
   34 format(20x,'pala',i3,' de',i3)
   35 format(2x,'Dfi =',f12.8,' rad  =',f8.4,' o')   
!      if(ib.eq.npal) write(subrout(nsubr),31)  
!      if(ib.eq.npal) nsubr=nsubr+1
!      write(15,31)  
!      if(ib.eq.npal) write(6,31) 
      if(ib.eq.npal) write(outstd(tam),31) 
      if(ib.eq.npal) tam=tam+1
   31 format(2x)    
c
      open(unit=1337,file='datos.txt')
      do 1 npa=1,npan   
      do 2 ir=1,nr+1  
      nhl=ir  
      atesting=npa
c
!$OMP PARALLEL DEFAULT(SHARED) 
cc!$OMP DO ORDERED FIRSTPRIVATE(ir,npa) REDUCTION(-: dist2)
cc!$OMP DO ORDERED PRIVATE(ir,npa,ik,ncapa) 
!$OMP DO FIRSTPRIVATE(ir,npa,ncapa) PRIVATE(dist2)
      do 3 ik=1,kult
c        
      fx(ik)=(pcz(npa,ncapa)-ze(ir,ik))*re(ir,ik)*dcos(fi(ir,ik))-
     &       (pcy(npa,ncapa)-ye(ir,ik))*c0                       
      fy(ik)=(pcx(npa,ncapa)-xe(ir,ik))*c0+
     &       (pcz(npa,ncapa)-ze(ir,ik))*re(ir,ik)*dsin(fi(ir,ik))  
      fz(ik)=((pcy(npa,ncapa)-ye(ir,ik))*re(ir,ik)*dsin(fi(ir,ik))+
     &       (pcx(npa,ncapa)-xe(ir,ik))*re(ir,ik)*dcos(fi(ir,ik))) 
     &       *(-1.)
ccc      fz(ik)=(-1.)*fz(ik)  
      dist2=(pcx(npa,ncapa)-xe(ir,ik))**2+
     &      (pcy(npa,ncapa)-ye(ir,ik))**2+
     &      (pcz(npa,ncapa)-ze(ir,ik))**2               
      dista(ik)=dsqrt(dist2)
cc      denom(ik)=dista(ik)**3                   
      denom(ik)=(dsqrt(dist2))**3                   
    3 continue      
!$OMP END DO
!$OMP END PARALLEL 
c               
c     sumatoria terminos impares
c
c      print*,nhl,' y ',ir,'--',atesting,' y ',npa 
      six= cero
      siy= cero
      siz= cero
      do 21 ik=2,kult-1,2
      six=six+fx(ik)/denom(ik)
      siy=siy+fy(ik)/denom(ik)
      siz=siz+fz(ik)/denom(ik)
   21 continue   
c
c     sumatoria terminos pares
c      
      spx= cero
      spy= cero
      spz= cero
      do 22 ik=3,kult-1,2
      spx=spx+fx(ik)/denom(ik)
      spy=spy+fy(ik)/denom(ik)
      spz=spz+fz(ik)/denom(ik)
   22 continue   
c      
      ciex(npa,nhl)=ciex(npa,nhl)+
     &               (fx(1)/denom(1)+fx(kult)/denom(kult)+4.*six+2.*spx)
      ciey(npa,nhl)=ciey(npa,nhl)+
     &               (fy(1)/denom(1)+fy(kult)/denom(kult)+4.*siy+2.*spy)
      ciez(npa,nhl)=ciez(npa,nhl)+
     &               (fz(1)/denom(1)+fz(kult)/denom(kult)+4.*siz+2.*spz)
c
      ciex(npa,nhl)=ciex(npa,nhl)*dfi3/ctte
      ciey(npa,nhl)=ciey(npa,nhl)*dfi3/ctte
      ciez(npa,nhl)=ciez(npa,nhl)*dfi3/ctte
c        
      if(indice.ne.1) goto 188
      if(ib.ne.1) goto 188
c
c    Coeficientes de influencia de la estela x,y,z (npa=nr,nhl=nr/2)
c               
      if(npa.ne.nr) goto 88
      if(ir.ne.(nr/2)) goto 88
c
      valx=0.5*dfi*fx(1)/denom(1)/ctte                     
      valy=0.5*dfi*fy(1)/denom(1)/ctte                     
      valz=0.5*dfi*fz(1)/denom(1)/ctte                     
c                             
c      in1=in1+1
c
      do 10 ik=1,kult
c
c      write(33,44) ik,re(ir,ik)/rt,ze(ir,ik)/rt,fi(ir,ik),
c     &             dista(ik)/rt,denom(ik),1./denom(ik),
c     &             dfi*fx(ik)/denom(ik)/ctte,
c     &             dfi*fy(ik)/denom(ik)/ctte,
c     &             dfi*fz(ik)/denom(ik)/ctte,valx,valy,valz
      write(integ1(ik),44) ik,re(ir,ik)/rt,ze(ir,ik)/rt,fi(ir,ik),
     &             dista(ik)/rt,denom(ik),1./denom(ik),
     &             dfi*fx(ik)/denom(ik)/ctte,
     &             dfi*fy(ik)/denom(ik)/ctte,
     &             dfi*fz(ik)/denom(ik)/ctte,valx,valy,valz
c         
      if(ik.eq.kult)goto 69 
      const=1.
      if(ik.eq.(kult-1)) const=0.5
      valx=valx+const*dfi*fx(ik+1)/denom(ik+1)/ctte                     
      valy=valy+const*dfi*fy(ik+1)/denom(ik+1)/ctte                     
      valz=valz+const*dfi*fz(ik+1)/denom(ik+1)/ctte  
   69 continue                      
c                                 
      if(ik.eq.kult) then
c      write(33,44)ik,re(ir,ik)/rt,ze(ir,ik)/rt,fi(ir,ik),
c     &             dista(ik)/rt,denom(ik),1./denom(ik),
c     &             dfi*fx(ik)/denom(ik)/ctte,
c     &             dfi*fy(ik)/denom(ik)/ctte,
c     &             dfi*fz(ik)/denom(ik)/ctte,
c     &             ciex(npa,nhl),ciey(npa,nhl),ciez(npa,nhl)
      write(integ1(ik+1),44)ik,re(ir,ik)/rt,ze(ir,ik)/rt,fi(ir,ik),
     &             dista(ik)/rt,denom(ik),1./denom(ik),
     &             dfi*fx(ik)/denom(ik)/ctte,
     &             dfi*fy(ik)/denom(ik)/ctte,
     &             dfi*fz(ik)/denom(ik)/ctte,
     &             ciex(npa,nhl),ciey(npa,nhl),ciez(npa,nhl)
      endif
c
   10 continue                    
   88 continue
c
c    Coeficientes de influencia de la estela x,y,z (npa=nr/2,nhl=nr+1)
c               
      if(npa.ne.(nr/2)) goto 288
      if(ir.ne.(nr+1)) goto 288
c
      valx=0.5*dfi*fx(1)/denom(1)/ctte                     
      valy=0.5*dfi*fy(1)/denom(1)/ctte                     
      valz=0.5*dfi*fz(1)/denom(1)/ctte                     
c
c      in2=in2+1                             
c
      do 210 ik=1,kult
c
c      write(39,44) ik,re(ir,ik)/rt,ze(ir,ik)/rt,fi(ir,ik),
c     &             dista(ik)/rt,denom(ik),1./denom(ik),
c     &             dfi*fx(ik)/denom(ik)/ctte,
c     &             dfi*fy(ik)/denom(ik)/ctte,
c     &             dfi*fz(ik)/denom(ik)/ctte,valx,valy,valz
      write(integ2(ik),44) ik,re(ir,ik)/rt,ze(ir,ik)/rt,fi(ir,ik),
     &             dista(ik)/rt,denom(ik),1./denom(ik),
     &             dfi*fx(ik)/denom(ik)/ctte,
     &             dfi*fy(ik)/denom(ik)/ctte,
     &             dfi*fz(ik)/denom(ik)/ctte,valx,valy,valz
c         
      if(ik.eq.kult)goto 269 
      const=1.
      if(ik.eq.(kult-1)) const=0.5
      valx=valx+const*dfi*fx(ik+1)/denom(ik+1)/ctte                     
      valy=valy+const*dfi*fy(ik+1)/denom(ik+1)/ctte                     
      valz=valz+const*dfi*fz(ik+1)/denom(ik+1)/ctte  
  269 continue                      
c                                 
      if(ik.eq.kult)then
c      write(39,44)ik,re(ir,ik)/rt,ze(ir,ik)/rt,fi(ir,ik),
c     &             dista(ik)/rt,denom(ik),1./denom(ik),
c     &             dfi*fx(ik)/denom(ik)/ctte,
c     &             dfi*fy(ik)/denom(ik)/ctte,
c     &             dfi*fz(ik)/denom(ik)/ctte,
c     &             ciex(npa,nhl),ciey(npa,nhl),ciez(npa,nhl)
      write(integ2(ik+1),44)ik,re(ir,ik)/rt,ze(ir,ik)/rt,fi(ir,ik),
     &             dista(ik)/rt,denom(ik),1./denom(ik),
     &             dfi*fx(ik)/denom(ik)/ctte,
     &             dfi*fy(ik)/denom(ik)/ctte,
     &             dfi*fz(ik)/denom(ik)/ctte,
     &             ciex(npa,nhl),ciey(npa,nhl),ciez(npa,nhl)
      endif
c
  210 continue                               
  288 continue
c     
   44 format(1x,i4,1x,f6.4,3(1x,f10.4),1x,f12.4,1x,f12.10,6(1x,f10.7))
c
  188 continue                           
    2 continue
    1 continue                         
    4 continue
      close(1337)
c
      return
      end
c
c-----------------------------------------------------------------------
c
      function radloc(zeta,rdisk,redvel)
c
c    Calculo del radio local del hilo vorticoso considerando un tubo de
c    corriente definido por una fuente en el origen y e = 0.
c    Resolucion ec. de tercer grado; Ref.: Korn & Korn, Mathematical 
c    Handbook for Scientist and Engineers.
c
      implicit real*8 (a-h,o-z)
c    
      cero = 0.d0
       uno = 1.d0
        pi = 4.d0*datan(uno)
c      
      if(zeta.eq.cero) yo=rdisk
      if(zeta.eq.cero) goto 21
      angle60=60.*pi/180.
c
      aa=zeta**2-2.*rdisk**2
      bb=(rdisk**2-2.*zeta**2)*rdisk**2
      cc=(1.-redvel**2)*rdisk**4*zeta**2
      pp=bb-(aa**2)/3.
      qq=cc-(aa*bb)/3.+2.*(aa/3.)**3
      cQ=(pp/3.)**3+(qq/2.)**2
      if(cQ.eq.cero) yo=rdisk
      if(cQ.eq.cero) goto 21
      if(cQ.lt.cero) goto 20
c
c    cQ > 0
c
      raiz=dsqrt(cQ)
      expo=1./3.
      cA3=raiz-(qq/2.)
      cB3=-raiz-(qq/2.)
c
      indexa=1
      indexb=1
      if(cA3.lt.cero) indexa=-1
      if(cB3.lt.cero) indexb=-1
c
      cA=(indexa*cA3)**expo
      cB=(indexb*cB3)**expo
      cA=cA*indexa
      cB=cB*indexb
c
      ww=cA+cB
      radic=ww-(aa/3.)
      yo=dsqrt(radic)
      goto 21
c
   20 continue
c
c    cQ < 0
c
      rad1=(-1.)*(pp/3.)**3
      root1=dsqrt(rad1)
      cosalf=(-1.)*qq/(2.*root1)
      alf=dacos(cosalf)
      alf3=alf/3.
      rad2=(-1.)*(pp/3.)
      root2=dsqrt(rad2)
      if(zeta.gt.cero) ww=2.*root2*dcos(alf3)
      if(zeta.lt.cero) ww=(-2.)*root2*dcos(alf3+angle60)
      radic=ww-(aa/3.)
      yo=dsqrt(radic)
c
   21 continue
c   
      radloc=yo
c
      return
      end
c
c-----------------------------------------------------------------------
c
      subroutine coefin
c
c    Calculo de los coeficientes de influencia totales para c/punto de
c    colocacion, incluyendo el efecto de los hilos vorticosos "en U"
c    que se ubican sobre los paneles dispuestos sobre el borde de fuga de
c    la pala 
c
c.......................................................................
c>
      implicit real*8 (a-h,o-z)
c
      parameter (maxir=51,maxio=51,maxip=11,maxnk=2001,
     &          mxir=maxir-1,mxio=maxio-1,mxip=maxip-1,
     &          maxro=maxir*maxio,mxro=mxir*mxio,mxnk=maxnk-1)
c
      common r(maxir),o(maxio),chord(maxir),yarc(maxir,maxio)
      common px(maxro),py(maxro),pz(maxro)
      common xbf(maxir),ybf(maxir),zbf(maxir),rbf(maxir)
      common xe(maxir,maxnk),ye(maxir,maxnk),ze(maxir,maxnk),
     &       re(maxir,maxnk),fi(maxir,maxnk),fifa(mxro,5),fipri(mxro,5)
c     
      common p1x(mxro),p1y(mxro),p1z(mxro),      
     &       p2x(mxro),p2y(mxro),p2z(mxro),
     &       p3x(mxro),p3y(mxro),p3z(mxro),
     &       p4x(mxro),p4y(mxro),p4z(mxro),
     &       pax(mxro),pay(mxro),paz(mxro),
     &       pbx(mxro),pby(mxro),pbz(mxro)
c
      common pcx(mxro,maxip),pcy(mxro,maxip),pcz(mxro,maxip),
     &       area(mxro),ss1(mxro,maxip),ss2(mxro,maxip),
     &       vnx(mxro),vny(mxro),vnz(mxro),Vinf(mxro)
c
      common gamma(mxro),circ(maxro),carga(mxro),theta(1)  
      common ciex(mxro,maxir),ciey(mxro,maxir),ciez(mxro,maxir),
     &       cix1tmp(mxro*mxro),ciy1tmp(mxro*mxro),ciz1tmp(mxro*mxro),
     &       cix2tmp(mxro*mxro),ciy2tmp(mxro*mxro),ciz2tmp(mxro*mxro)
      common vix(mxro,maxip),viy(mxro,maxip),viz(mxro,maxip),
     &       vi(mxro,maxip),vtgx(mxro,maxip),vtgy(mxro,maxip),
     &       urx(mxro,maxip),ury(mxro,maxip),urz(mxro,maxip)     
      common urex(mxro),urey(mxro),urez(mxro),
     &       urix(mxro),uriy(mxro),uriz(mxro)
c
      common U,UU,omega,c0,a,rh,rt,oi,of,pf,ch,ct,zlim,factor1,factor2
      common pi,beta,cero,signo,redvel,coefa,hc,dfi,alfac,c1,c2,distan
      common indice,index0,index1,index2,index3,index4,index5,index6,      
     &       index7,index8,index9,index10,index11,index12,alfac0      
      common npan,nodos,ncapa,npal,npaso,nr,no,np,nk,kult,inic,in1,in2, 
     &       in3,nsubr,nsld2
c
      character integ1(maxro)*150,integ2(maxro)*150,gamastr(maxro)*70,
     &          circostr(maxro)*70,salida2out(102)*95
c     Variable para internal file del archivo global subr.out
c     el cual lleva los mismos datos que la salida standar
      character subrout(500)*60
c                      
                      
      common integ1,integ2,gamastr,circostr,subrout,salida2out
c
c<
c.......................................................................
c
      nav= npan-nr
c                 
CCC      do 5 ib=1,npal   
      ib=1
      kon=1
      do 4 npa=1,npan
      do 3 nv=1,npan
c                
!      read(42)cinfx
!      read(43)cinfy
!      read(44)cinfz                                     
      cinfx=cix1tmp(kon)
      cinfy=ciy1tmp(kon)
      cinfz=ciz1tmp(kon)
c
      if(nv.le.nav) goto 10         
c
      nhl= nv-nav
c
      cinfx= cinfx+ciex(npa,nhl)-ciex(npa,nhl+1)
      cinfy= cinfy+ciey(npa,nhl)-ciey(npa,nhl+1)
      cinfz= cinfz+ciez(npa,nhl)-ciez(npa,nhl+1)  
c   
   10 continue   
c                
!      write(45)cinfx
!      write(46)cinfy
!      write(47)cinfz                                     
      cix2tmp(kon)=cinfx
      ciy2tmp(kon)=cinfy
      ciz2tmp(kon)=cinfz
      kon=kon+1
c              
    3 continue
    4 continue    
    5 continue  
c
!      rewind(42)
!      rewind(43)
!      rewind(44)
!      rewind(45)
!      rewind(46)
!      rewind(47)
c                  
      return
      end
c                     
c-----------------------------------------------------------------------
c
      subroutine circulac(outstd,tam)
c
c    Calculo de la circulacion asociada a la estela y a cada anillo vorticoso  
c                                         
c.......................................................................
c>
      implicit real*8 (a-h,o-z)
c
      parameter (maxir=51,maxio=51,maxip=11,maxnk=2001,
     &          mxir=maxir-1,mxio=maxio-1,mxip=maxip-1,
     &          maxro=maxir*maxio,mxro=mxir*mxio,mxnk=maxnk-1)
c
      common r(maxir),o(maxio),chord(maxir),yarc(maxir,maxio)
      common px(maxro),py(maxro),pz(maxro)
      common xbf(maxir),ybf(maxir),zbf(maxir),rbf(maxir)
      common xe(maxir,maxnk),ye(maxir,maxnk),ze(maxir,maxnk),
     &       re(maxir,maxnk),fi(maxir,maxnk),fifa(mxro,5),fipri(mxro,5)
c     
      common p1x(mxro),p1y(mxro),p1z(mxro),      
     &       p2x(mxro),p2y(mxro),p2z(mxro),
     &       p3x(mxro),p3y(mxro),p3z(mxro),
     &       p4x(mxro),p4y(mxro),p4z(mxro),
     &       pax(mxro),pay(mxro),paz(mxro),
     &       pbx(mxro),pby(mxro),pbz(mxro)
c
      common pcx(mxro,maxip),pcy(mxro,maxip),pcz(mxro,maxip),
     &       area(mxro),ss1(mxro,maxip),ss2(mxro,maxip),
     &       vnx(mxro),vny(mxro),vnz(mxro),Vinf(mxro)
c
      common gamma(mxro),circ(maxro),carga(mxro),theta(1)  
      common ciex(mxro,maxir),ciey(mxro,maxir),ciez(mxro,maxir),
     &       cix1tmp(mxro*mxro),ciy1tmp(mxro*mxro),ciz1tmp(mxro*mxro),
     &       cix2tmp(mxro*mxro),ciy2tmp(mxro*mxro),ciz2tmp(mxro*mxro)
      common vix(mxro,maxip),viy(mxro,maxip),viz(mxro,maxip),
     &       vi(mxro,maxip),vtgx(mxro,maxip),vtgy(mxro,maxip),
     &       urx(mxro,maxip),ury(mxro,maxip),urz(mxro,maxip)     
      common urex(mxro),urey(mxro),urez(mxro),
     &       urix(mxro),uriy(mxro),uriz(mxro)
c
      common U,UU,omega,c0,a,rh,rt,oi,of,pf,ch,ct,zlim,factor1,factor2
      common pi,beta,cero,signo,redvel,coefa,hc,dfi,alfac,c1,c2,distan
      common indice,index0,index1,index2,index3,index4,index5,index6,      
     &       index7,index8,index9,index10,index11,index12,alfac0      
      common npan,nodos,ncapa,npal,npaso,nr,no,np,nk,kult,inic,in1,in2, 
     &       in3,nsubr,nsld2
c
      character integ1(maxro)*150,integ2(maxro)*150,gamastr(maxro)*70,
     &          circostr(maxro)*70,salida2out(102)*95
c     Variable para internal file del archivo global subr.out
c     el cual lleva los mismos datos que la salida standar
      character subrout(500)*60
c                      
                      
      common integ1,integ2,gamastr,circostr,subrout,salida2out
c
c<
c.......................................................................
c
c     Primera parte:
c
c    verificacion de la nulidad de velocidades normales al punto de control
c    de cada panel (i.e., @ 3c/4)  (capa No.1)     
c
! -------------------------------------------------------
! cindgtmp y coefgtmp sirven para reemplazar a los files temporales coefg.tmp y
! cindg.tmp. incoeg es el indice para recorrer coefgtmp, ya que se incrementa
! independiente del loop interno que genera los datos de coefgtmp
      real*8 cindgtmp(npan),coefgtmp(npan*npan)
      integer incoefg
! ------------------------------------
      integer tam
      character outstd(50)*100
!  OUTSTD es un array de caracteres para llevar la salida estandar de la 
!  subrutina, en lugar de hacer write(6). Se difiere su escritura en 
!  pantalla hasta volver al programa Main. 
!  TAM lleva la cantidad de posiciones utilizadas en OUTSTD
!  Ambas variables van por parametro en el nombre de la subrutina.
! -------------------------------------------------------
      tam=1
!
      incoefg=1
      m=npan+1
      kon=1
c
      do 1 npa=1,npan
      do 2 nv =1,npan  
c                
!      read(45)cinfx
!      read(46)cinfy
!      read(47)cinfz                                     
      cinfx=cix2tmp(kon)
      cinfy=ciy2tmp(kon)
      cinfz=ciz2tmp(kon)
      kon=kon+1
c                                  
      if(npal.eq.1)sumbcx=cinfx
      if(npal.eq.1)sumbcy=cinfy
      if(npal.eq.1)sumbcz=cinfz
      if(npal.eq.1)goto 927
c      
      sumbcx= cero 
      sumbcy= cero
      sumbcz= cero    
c      
CCC      do 3 ib=1,npal   
      ib=1
c
      sumbcx= sumbcx+cinfx
      sumbcy= sumbcy+cinfy
      sumbcz= sumbcz+cinfz
    3 continue
c
  927 continue
      coefg= sumbcx*vnx(npa)+sumbcy*vny(npa)+sumbcz*vnz(npa) 
      !write(40)coefg    ! se cambia la escritura en disco por
      coefgtmp(incoefg)=coefg ! utilizacion de 1 array
      incoefg=incoefg+1
    2 continue 
c                    
      vtgx(npa,1)= omega*pcy(npa,1)*(-1.)
      vtgy(npa,1)= omega*pcx(npa,1)      
c      
      cindg= (-1.)*(vtgx(npa,1)*vnx(npa)+vtgy(npa,1)*vny(npa)+
     &              UU*vnz(npa))
      !write(41)cindg   ! se cambia escritura en disco por
      cindgtmp(npa)=cindg ! escritura en array 
    1 continue
c
      !rewind(40)                   
      !rewind(41)                   
!      rewind(45)                   
!      rewind(46)                   
!      rewind(47)                   
c                 
c     Segunda parte:
c
c    resolucion del sistema de {npa x npa} ecuaciones algebraicas lineales
c
!      write(6,5) npan
      write(outstd(tam),5) npan
      write(outstd(tam+1),'(a1)') ""
      tam=tam+2
      write(subrout(nsubr),5)npan 
      nsubr=nsubr+1
!      write(15,5)npan 
    5 format(5x,'solgauss',i6)                           
c
      call solgauss(npan,gamma,coefgtmp,cindgtmp)  
c                  
c     Tercera parte:
c
c    distribucion de circulacion de cada anillo vorticoso, y del
c    horseshoe de los paneles ubicados en el borde de fuga de la pala
c    (gamma)
c                
      uno=1.d0
      kio=1             
      kkk=1          
c
      do 150 npa=1,npan 
      gamadm= 100.*gamma(npa)/(omega*rt**2)
      if(index2.eq.0) 
!     &  write(16,200) npa,pcx(npa,1),pcx(npa,1)/rt,gamma(npa),gamadm,
!     &                (o(kkk)+(o(kkk+1)-o(kkk))/4.)/(of-oi) 
     &  write(gamastr(npa),200) npa,pcx(npa,1),pcx(npa,1)/rt,gamma(npa),
     &                gamadm,(o(kkk)+(o(kkk+1)-o(kkk))/4.)/(of-oi) 
      if(index2.ne.0) 
!     &  write(16,200) npa,pcx(npa,1),pcx(npa,1)/rt,gamma(npa),gamadm,
!     &                o(kkk)+(o(kkk+1)-o(kkk))/4. 
     &  write(gamastr(npa),200) npa,pcx(npa,1),pcx(npa,1)/rt,gamma(npa),
     &                gamadm,o(kkk)+(o(kkk+1)-o(kkk))/4. 
c
      kio=kio+1
      if(kio.gt.nr) kio=1 
      if(kio.eq.1)  kkk=kkk+1              
c
  150 continue
c     
      kont=npan+1                        
      do 112 ir=1,nr
      xcbf=(xbf(ir)+xbf(ir+1))/2.
!      write(16,200) npan+ir,xcbf,xcbf/rt,cero,cero,uno
      write(gamastr(kont),200) npan+ir,xcbf,xcbf/rt,cero,cero,uno
      kont=kont+1
  112 continue     
c
  200 format(1x,i4,2(1x,f8.4),2(1x,f14.8),1x,f8.4)
c
c    representacion de la diferencia de circulacion (circ)
c    sobre cada hilo vortico recto ligado al cuarto de cuerda del panel
c
      uno=1.
      kio=1             
      kkk=1          
c               
      do 10 npa=1,npan
      if(npa.le.nr) circ(npa)=gamma(npa)
      if(npa.gt.nr) circ(npa)=gamma(npa)-gamma(npa-nr)  
c
      if(index2.eq.0) 
!     &   write(28,11) npa,pcx(npa,1)/rt,circ(npa),
!     &                100.*circ(npa)/(omega*rt**2),
!     &                (o(kkk)+(o(kkk+1)-o(kkk))/4.)/(of-oi) 
     &   write(circostr(npa),11) npa,pcx(npa,1)/rt,circ(npa),
     &                100.*circ(npa)/(omega*rt**2),
     &                (o(kkk)+(o(kkk+1)-o(kkk))/4.)/(of-oi) 
      if(index2.ne.0) 
!     &   write(28,11) npa,pcx(npa,1)/rt,circ(npa),
!     &                100.*circ(npa)/(omega*rt**2),
!     &                o(kkk)+(o(kkk+1)-o(kkk))/4. 
     &   write(circostr(npa),11) npa,pcx(npa,1)/rt,circ(npa),
     &                100.*circ(npa)/(omega*rt**2),
     &                o(kkk)+(o(kkk+1)-o(kkk))/4. 
c
      kio=kio+1
      if(kio.gt.nr) kio=1 
      if(kio.eq.1)  kkk=kkk+1              
c                
   10 continue                                                         
c                             
      kont=npan+1
      do 12 ir=1,nr
      xcbf=(xbf(ir)+xbf(ir+1))/2.
!      write(28,11) npan+ir,xcbf/rt,cero,cero,uno
      write(circostr(kont),11) npan+ir,xcbf/rt,cero,cero,uno
      kont=kont+1
   12 continue     
   11 format(1x,i5,1x,f8.4,1x,f12.6,1x,f10.6,1x,f9.6)                                            
c      
      return
      end
c
c-----------------------------------------------------------------------
c
      subroutine solgauss(npan,gama,tmpcoefg,tmpcindg)
c
c     Resolucion del sistema [coefg].{gamma} = {}
c     de (nxn), por el metodo de eliminacion de Gauss 
c     Ref.: Algoritmos Numericos (Jacobo Gordon)
c
c.......................................................................
c
      implicit real*8 (a-h,o-z)
c
      parameter (maxir=51,maxio=51,
     &          mxir=maxir-1,mxio=maxio-1,mxro=mxir*mxio)
c
      dimension coefg(mxro,mxro+1),gama(mxro)
      real*8 tmpcoefg(mxro*mxro),tmpcindg(mxro)
c
c.......................................................................
c
      m=npan+1
      incfg=1
c                                 
      do 1 i=1,npan
      do 2 j=1,npan  
      !read(40)cfg
      !incfg=((i-1)*npan)+j
      cfg=tmpcoefg(incfg)
      coefg(i,j)=cfg
      incfg=incfg+1
    2 continue
      !read(41)cig
      cig=tmpcindg(i)
      coefg(i,m)=cig
    1 continue  
      print*,'INCFG= ',incfg
c
      !rewind(40)                   
      !rewind(41)                   
c                 
      do 120 i=2,npan
      do 120 j=i,npan
      if(coefg(i-1,i-1))110,115,110
  115 m1=i-1
      do 121 k=i,npan
      if(coefg(k,m1))130,121,130
  130 do 122 m2=m1,m
      ap=coefg(k,m2)
      coefg(k,m2)=coefg(m1,m2)
  122 coefg(m1,m2)=ap
  121 continue
  110 rr=coefg(j,i-1)/coefg(i-1,i-1)
      do 120 k=i,m
  120 coefg(j,k)=coefg(j,k)-rr*coefg(i-1,k)
      do 140 i=2,npan
      k=npan-i+2
      rr=coefg(k,m)/coefg(k,k)
      do 140 j=i,npan
      l=npan-j+1
      coefg(l,m)=coefg(l,m)-rr*coefg(l,k)            
  140 continue
c                           
      do 150 npa=1,npan
      gama(npa)= coefg(npa,m)/coefg(npa,npa)
  150 continue
c  
      print*,'en gama ',gama(1)
      return
      end
c
c-----------------------------------------------------------------------
c
      subroutine veloc
c
c     Calculo de velocidades inducidas y resultantes @ Ptos.colocacion
c
c.......................................................................
c>
      implicit real*8 (a-h,o-z)
c
      parameter (maxir=51,maxio=51,maxip=11,maxnk=2001,
     &          mxir=maxir-1,mxio=maxio-1,mxip=maxip-1,
     &          maxro=maxir*maxio,mxro=mxir*mxio,mxnk=maxnk-1)
c
      common r(maxir),o(maxio),chord(maxir),yarc(maxir,maxio)
      common px(maxro),py(maxro),pz(maxro)
      common xbf(maxir),ybf(maxir),zbf(maxir),rbf(maxir)
      common xe(maxir,maxnk),ye(maxir,maxnk),ze(maxir,maxnk),
     &       re(maxir,maxnk),fi(maxir,maxnk),fifa(mxro,5),fipri(mxro,5)
c     
      common p1x(mxro),p1y(mxro),p1z(mxro),      
     &       p2x(mxro),p2y(mxro),p2z(mxro),
     &       p3x(mxro),p3y(mxro),p3z(mxro),
     &       p4x(mxro),p4y(mxro),p4z(mxro),
     &       pax(mxro),pay(mxro),paz(mxro),
     &       pbx(mxro),pby(mxro),pbz(mxro)
c
      common pcx(mxro,maxip),pcy(mxro,maxip),pcz(mxro,maxip),
     &       area(mxro),ss1(mxro,maxip),ss2(mxro,maxip),
     &       vnx(mxro),vny(mxro),vnz(mxro),Vinf(mxro)
c
      common gamma(mxro),circ(maxro),carga(mxro),theta(1)  
      common ciex(mxro,maxir),ciey(mxro,maxir),ciez(mxro,maxir),
     &       cix1tmp(mxro*mxro),ciy1tmp(mxro*mxro),ciz1tmp(mxro*mxro),
     &       cix2tmp(mxro*mxro),ciy2tmp(mxro*mxro),ciz2tmp(mxro*mxro)
      common vix(mxro,maxip),viy(mxro,maxip),viz(mxro,maxip),
     &       vi(mxro,maxip),vtgx(mxro,maxip),vtgy(mxro,maxip),
     &       urx(mxro,maxip),ury(mxro,maxip),urz(mxro,maxip)     
      common urex(mxro),urey(mxro),urez(mxro),
     &       urix(mxro),uriy(mxro),uriz(mxro)
c
      common U,UU,omega,c0,a,rh,rt,oi,of,pf,ch,ct,zlim,factor1,factor2
      common pi,beta,cero,signo,redvel,coefa,hc,dfi,alfac,c1,c2,distan
      common indice,index0,index1,index2,index3,index4,index5,index6,      
     &       index7,index8,index9,index10,index11,index12,alfac0      
      common npan,nodos,ncapa,npal,npaso,nr,no,np,nk,kult,inic,in1,in2, 
     &       in3,nsubr,nsld2
c
      character integ1(maxro)*150,integ2(maxro)*150,gamastr(maxro)*70,
     &          circostr(maxro)*70,salida2out(102)*95
c     Variable para internal file del archivo global subr.out
c     el cual lleva los mismos datos que la salida standar
      character subrout(500)*60
c                      
                      
      common integ1,integ2,gamastr,circostr,subrout,salida2out
c
c<
c.......................................................................
c                                 
c     Distribucion de velocidades inducidas p/c/panel, sobre c/capa.
c     Velocidades evaluadas en el punto de colocacion de cada panel.
c
      sarea = cero
c                         
      sviax = cero
      sviay = cero
      sviaz = cero
      kon=1
c
      do 1 npa=1,npan
c           
      sumx = cero
      sumy = cero
      sumz = cero
c        
      do 2 nv=1,npan 
CCC      do 9 ib=1,npal  
      ib=1
c                                    
!      read(45)cinfx                     
!      read(46)cinfy                     
!      read(47)cinfz
      cinfx=cix2tmp(kon)
      cinfy=ciy2tmp(kon)
      cinfz=ciz2tmp(kon)
      kon=kon+1
c                  
      sumx = sumx+cinfx*gamma(nv)
      sumy = sumy+cinfy*gamma(nv)
      sumz = sumz+cinfz*gamma(nv)
c                 
    9 continue       
    2 continue                    
c                                    
      vix(npa,ncapa)= sumx
      viy(npa,ncapa)= sumy
      viz(npa,ncapa)= sumz  
c                     
      vi2=sumx**2+sumy**2+sumz**2
      vi(npa,ncapa)= dsqrt(vi2)      
c                              
      sviax = sviax+vix(npa,ncapa)*area(npa)*vnx(npa) 
      sviay = sviay+viy(npa,ncapa)*area(npa)*vny(npa) 
      sviaz = sviaz+viz(npa,ncapa)*area(npa)*vnz(npa) 
c
      sarea = sarea+area(npa)                
c
    1 continue
c                
!      rewind(45)
!      rewind(46)
!      rewind(47)
c
c     velocidad inducida media sobre cada capa                                
c                                 
      if(ncapa.ne.1.and.index2.eq.0) goto 5
c                  
      superf = sarea
      vixmed = sviax/superf
      viymed = sviay/superf
      vizmed = sviaz/superf   
c      
      caudal = sviax+sviay+sviaz
      vimedq = caudal/superf
c
      vimed2= vixmed**2+viymed**2+vizmed**2
      vimed = dsqrt(vimed2)     
c
      write(salida2out(nsld2),7)superf,vimedq
      write(salida2out(nsld2+1),71)vimed,vixmed,viymed,vizmed
      write(salida2out(nsld2+2),'(a1)') ""
      nsld2=nsld2+3
    7 format(2x,'Area pala [m2] =',f9.4,9x,'caudal/area [m/s] =',f9.4)
   71 format(2x,'Vi media [m/s] =',f9.4,9x,'(x,y,z) =',3(f9.4,2x))  
!      write(50,7)superf,vimedq,vimed,vixmed,viymed,vizmed
!    7 format(2x,'Area pala [m2] =',f9.4,9x,'caudal/area [m/s] =',
!     &       f9.4,/,2x,'Vi media [m/s] =',
!     &       f9.4,9x,'(x,y,z) =',3(f9.4,2x),/)  
    5 continue  
c                                 
c     Distribucion de velocidades resultantes p/c/panel, sobre c/capa.
c     Velocidades evaluadas en el punto de colocacion de cada panel, Pc.
c
c     Tabulacion solo para la pala, en los puntos de colocacion @ 3c/4
c     (ncapa=1, indice = 1)  y  @ c/4 (ncapa = 1, indice = 2)
c
      do 4 npa=1,npan  
c
      vtgx(npa,ncapa)= omega*pcy(npa,ncapa)*(-1.)
      vtgy(npa,ncapa)= omega*pcx(npa,ncapa)      
c     
      urx(npa,ncapa)= vix(npa,ncapa)+vtgx(npa,ncapa)
      ury(npa,ncapa)= viy(npa,ncapa)+vtgy(npa,ncapa)
      urz(npa,ncapa)= viz(npa,ncapa)+UU
c
      Ures2= urx(npa,ncapa)**2+ury(npa,ncapa)**2+urz(npa,ncapa)**2
      Ures = dsqrt(Ures2)           
c
c	solamente PRIMERA y SEGUNDA PARTE:    VELOCIDADES DIMENSIONALES
c               ncapa = 1,   ncapa = 10   
c										  velxyz.txt
      if(indice.lt.3)						
     &write(13,333)   npa,
     &            pcx(npa,ncapa),pcy(npa,ncapa),pcz(npa,ncapa),
     &            urx(npa,ncapa),ury(npa,ncapa),urz(npa,ncapa),Ures,
     &            indice  
c
c	solamente PRIMERA y SEGUNDA PARTE:	  VELOCIDADES ADIMENSIONALES
c               ncapa = 1,   ncapa = 10   
c										  velpotAD.txt
      if(indice.lt.3)
     &write(22,3) indice,npa,
     &            pcx(npa,ncapa),pcy(npa,ncapa),pcz(npa,ncapa),
     &            vtgx(npa,ncapa)/U,vtgy(npa,ncapa)/U,UU/U,  
     &            urx(npa,ncapa)/U,ury(npa,ncapa)/U,urz(npa,ncapa)/U,
     &            Ures/U  
c										  velindAD.txt
      if(indice.lt.3)
     &write(21,3) indice,npa,
     &            pcx(npa,ncapa),pcy(npa,ncapa),pcz(npa,ncapa),
     &            vix(npa,ncapa)/U,viy(npa,ncapa)/U,viz(npa,ncapa)/U,  
     &            urx(npa,ncapa)/U,ury(npa,ncapa)/U,urz(npa,ncapa)/U,  
     &            Ures/U  
c
c	solamente PRIMERA y TERCERA PARTE:    VELOCIDADES DIMENSIONALES
c               ncapa de 1 a 9
c										  velcapae.txt
      if(indice.eq.2)	goto 33
     	if(ncapa.le.5)
     &write(53,335) ncapa,npa,
     &            pcx(npa,ncapa),pcy(npa,ncapa),pcz(npa,ncapa),
     &            urx(npa,ncapa),ury(npa,ncapa),urz(npa,ncapa),Ures  
   33 continue
c										  velcapai.txt
      if(indice.eq.2) goto 34
     	if(ncapa.gt.5)
     &write(54,335) ncapa,npa,
     &            pcx(npa,ncapa),pcy(npa,ncapa),pcz(npa,ncapa),
     &            urx(npa,ncapa),ury(npa,ncapa),urz(npa,ncapa),Ures  
   34 continue
c
    4 continue
    3 format(1x,2(1x,i4),3(1x,f7.3),7(1x,f9.4)) 
  333 format(1x,i4,3(1x,f9.5),4(1x,f9.4),1x,i4) 
  335 format(1x,2(1x,i4),3(1x,f9.5),4(1x,f9.4)) 
c
c.......................................................................
c                                 
c     Tabulacion de velocidades inducidas solo para la pala, 
c     en los puntos de colocacion @ 3c/4 & c/4 (ncapa=1, indice = 1 y 2)
c                   
c  										  vix, viy, viz.txt
      mo=1         
      if(no.gt.20)mo=2
      if(indice.gt.2) goto 12
      do 10 ir=1,nr      
      write(34,11) pcx(ir,ncapa)/rt,
     &             (vix(ir+(io-1)*nr,ncapa),io=1,no,mo)
      write(35,11) pcx(ir,ncapa)/rt,
     &             (viy(ir+(io-1)*nr,ncapa),io=1,no,mo)
      write(36,11) pcx(ir,ncapa)/rt,
     &             (viz(ir+(io-1)*nr,ncapa),io=1,no,mo)
   10 continue
   11 format(1x,f7.4,20(1x,f8.4))  
c     
      write(34,13)
      write(35,13)
      write(36,13)
   13 format(2x)   
c   
   12 continue 
c
c.......................................................................
c
      return
      end
c
c-----------------------------------------------------------------------
c
      subroutine velsuper
c
c     Calculo de velocidades resultantes sobre ambas superficies:
c     Extrados (e) e Intrados (i)
c
c.......................................................................
c>
      implicit real*8 (a-h,o-z)
c
      parameter (maxir=51,maxio=51,maxip=11,maxnk=2001,
     &          mxir=maxir-1,mxio=maxio-1,mxip=maxip-1,
     &          maxro=maxir*maxio,mxro=mxir*mxio,mxnk=maxnk-1)
c
      common r(maxir),o(maxio),chord(maxir),yarc(maxir,maxio)
      common px(maxro),py(maxro),pz(maxro)
      common xbf(maxir),ybf(maxir),zbf(maxir),rbf(maxir)
      common xe(maxir,maxnk),ye(maxir,maxnk),ze(maxir,maxnk),
     &       re(maxir,maxnk),fi(maxir,maxnk),fifa(mxro,5),fipri(mxro,5)
c     
      common p1x(mxro),p1y(mxro),p1z(mxro),      
     &       p2x(mxro),p2y(mxro),p2z(mxro),
     &       p3x(mxro),p3y(mxro),p3z(mxro),
     &       p4x(mxro),p4y(mxro),p4z(mxro),
     &       pax(mxro),pay(mxro),paz(mxro),
     &       pbx(mxro),pby(mxro),pbz(mxro)
c
      common pcx(mxro,maxip),pcy(mxro,maxip),pcz(mxro,maxip),
     &       area(mxro),ss1(mxro,maxip),ss2(mxro,maxip),
     &       vnx(mxro),vny(mxro),vnz(mxro),Vinf(mxro)
c
      common gamma(mxro),circ(maxro),carga(mxro),theta(1)  
      common ciex(mxro,maxir),ciey(mxro,maxir),ciez(mxro,maxir),
     &       cix1tmp(mxro*mxro),ciy1tmp(mxro*mxro),ciz1tmp(mxro*mxro),
     &       cix2tmp(mxro*mxro),ciy2tmp(mxro*mxro),ciz2tmp(mxro*mxro)
      common vix(mxro,maxip),viy(mxro,maxip),viz(mxro,maxip),
     &       vi(mxro,maxip),vtgx(mxro,maxip),vtgy(mxro,maxip),
     &       urx(mxro,maxip),ury(mxro,maxip),urz(mxro,maxip)     
      common urex(mxro),urey(mxro),urez(mxro),
     &       urix(mxro),uriy(mxro),uriz(mxro)
c
      common U,UU,omega,c0,a,rh,rt,oi,of,pf,ch,ct,zlim,factor1,factor2
      common pi,beta,cero,signo,redvel,coefa,hc,dfi,alfac,c1,c2,distan
      common indice,index0,index1,index2,index3,index4,index5,index6,      
     &       index7,index8,index9,index10,index11,index12,alfac0      
      common npan,nodos,ncapa,npal,npaso,nr,no,np,nk,kult,inic,in1,in2, 
     &       in3,nsubr,nsld2
c
      character integ1(maxro)*150,integ2(maxro)*150,gamastr(maxro)*70,
     &          circostr(maxro)*70,salida2out(102)*95
c     Variable para internal file del archivo global subr.out
c     el cual lleva los mismos datos que la salida standar
      character subrout(500)*60
c                      
                      
      common integ1,integ2,gamastr,circostr,subrout,salida2out
c
c<
c.......................................................................
c                                 
c     Velocidades evaluadas en el punto de colocacion de cada panel, para
c     Extrados e Intrados      
c
c	Graficación segun envergadura (eje X)
c
      do 4 npa = 1,npan  
c
c     Extrados:
c     
      urex(npa)= 4.*urx(npa,2)- 6.*urx(npa,3)+ 4.*urx(npa,4)- urx(npa,5)
      urey(npa)= 4.*ury(npa,2)- 6.*ury(npa,3)+ 4.*ury(npa,4)- ury(npa,5)
      urez(npa)= 4.*urz(npa,2)- 6.*urz(npa,3)+ 4.*urz(npa,4)- urz(npa,5) 
c
      Ueres2= urex(npa)**2+urey(npa)**2+urez(npa)**2
      Ueres = dsqrt(Ueres2)           
c
c     Intrados:   
c  
      urix(npa)= 4.*urx(npa,6)- 6.*urx(npa,7)+ 4.*urx(npa,8)- urx(npa,9)
      uriy(npa)= 4.*ury(npa,6)- 6.*ury(npa,7)+ 4.*ury(npa,8)- ury(npa,9)
      uriz(npa)= 4.*urz(npa,6)- 6.*urz(npa,7)+ 4.*urz(npa,8)- urz(npa,9) 
c
      Uires2= urix(npa)**2+uriy(npa)**2+uriz(npa)**2
      Uires = dsqrt(Uires2)           
c
      Ures2= urx(npa,1)**2+ury(npa,1)**2+urz(npa,1)**2
      Ures = dsqrt(Ures2)           
c														  veltotal.txt
      write(55,33) npa,
     &             urx(npa,1),ury(npa,1),urz(npa,1),Ures,  
     &             urex(npa), urey(npa), urez(npa), Ueres,  
     &             urix(npa), uriy(npa), uriz(npa), Uires  
c														  vel01ext.txt
      write(56,34) npa,
     &             pcx(npa,1),pcy(npa,1),pcz(npa,1),
     &             urex(npa),urey(npa),urez(npa),Ueres  
c														  vel01int.txt
      write(57,34) npa,
     &             pcx(npa,1),pcy(npa,1),pcz(npa,1),
     &             urix(npa),uriy(npa),uriz(npa),Uires  
c
    4 continue
c
c	Graficación segun "cuerda" (eje Y)
c
	npa0 = 1
c
	do 1 nkkr = 1,nr
	do 2 nkko = 1,no
c
      npa = nkkr + nr*(nkko-1)
c
	if(npa.le.nr) durx  = cero
	if(npa.le.nr) dury  = cero
	if(npa.le.nr) durz  = cero
	if(npa.le.nr) durex = cero
	if(npa.le.nr) durey = cero
	if(npa.le.nr) durez = cero
	if(npa.le.nr) durix = cero
	if(npa.le.nr) duriy = cero
	if(npa.le.nr) duriz = cero
	if(npa.le.nr) goto 3
c
	durx  = urx(npa,1) - urx(npa0,1)
	dury  = ury(npa,1) - ury(npa0,1)
	durz  = urz(npa,1) - urz(npa0,1)
c
	durex = urex(npa)  - urex(npa0)
	durey = urey(npa)  - urey(npa0)
	durez = urez(npa)  - urez(npa0)
c
	durix = urix(npa)  - urix(npa0)
	duriy = uriy(npa)  - uriy(npa0)
	duriz = uriz(npa)  - uriz(npa0)
c
    3 continue
c
      Ueres2= urex(npa)**2+urey(npa)**2+urez(npa)**2
      Ueres = dsqrt(Ueres2)           
c
      Uires2= urix(npa)**2+uriy(npa)**2+uriz(npa)**2
      Uires = dsqrt(Uires2)           
c
      Ures2 = urx(npa,1)**2+ury(npa,1)**2+urz(npa,1)**2
      Ures  = dsqrt(Ures2)           
c														  vel02pvn.txt
      write(60,35) npa,									 
     &             pcx(npa,1),pcy(npa,1),pcz(npa,1),
     &             urx(npa,1),ury(npa,1),urz(npa,1),Ures,
     &             durx, dury, durz
c														  vel02ext.txt
      write(58,35) npa,
     &             pcx(npa,1),pcy(npa,1),pcz(npa,1),
     &             urex(npa),urey(npa),urez(npa),Ueres,
     &             durex,durey,durez
c														  vel02int.txt
      write(59,35) npa,									  
     &             pcx(npa,1),pcy(npa,1),pcz(npa,1),
     &             urix(npa),uriy(npa),uriz(npa),Uires,
     &             durix,duriy,duriz
c
    	npa0 = npa
	urx(npa,10) = urex(npa)				  
	ury(npa,10) = urex(npa)
	urz(npa,10) = urex(npa)
	urx(npa,11) = urix(npa)
	ury(npa,11) = urix(npa)
	urz(npa,11) = urix(npa)
c
    2 continue
    1 continue
c
   33 format(1x,i4,12(1x,f8.4)) 
   34 format(1x,i4,3(1x,f9.5),4(1x,f9.4)) 
   35 format(1x,i4,3(1x,f9.5),4(1x,f9.4),3(1x,f9.5)) 
c
      return
      end
c          
c-----------------------------------------------------------------------
c 
      subroutine presion1
c
c     distribucion de presiones sobre los puntos de colocacion, Pc 
c     (Indice = 1, ncapa = 1)
c
c     distribucion del coeficiente presiones sobre los puntos de colocacion 
c
c     @ 3c/4  (indice = 1)
c
c     Coefp = (Plocal-Pinf)/(0.5*densidad*Uinf^2) = 1 - S
c           
c     S = (Vlocal/Uinf)^2           
c
c.......................................................................
c>
      implicit real*8 (a-h,o-z)
c
      parameter (maxir=51,maxio=51,maxip=11,maxnk=2001,
     &          mxir=maxir-1,mxio=maxio-1,mxip=maxip-1,
     &          maxro=maxir*maxio,mxro=mxir*mxio,mxnk=maxnk-1)
c
      common r(maxir),o(maxio),chord(maxir),yarc(maxir,maxio)
      common px(maxro),py(maxro),pz(maxro)
      common xbf(maxir),ybf(maxir),zbf(maxir),rbf(maxir)
      common xe(maxir,maxnk),ye(maxir,maxnk),ze(maxir,maxnk),
     &       re(maxir,maxnk),fi(maxir,maxnk),fifa(mxro,5),fipri(mxro,5)
c     
      common p1x(mxro),p1y(mxro),p1z(mxro),      
     &       p2x(mxro),p2y(mxro),p2z(mxro),
     &       p3x(mxro),p3y(mxro),p3z(mxro),
     &       p4x(mxro),p4y(mxro),p4z(mxro),
     &       pax(mxro),pay(mxro),paz(mxro),
     &       pbx(mxro),pby(mxro),pbz(mxro)
c
      common pcx(mxro,maxip),pcy(mxro,maxip),pcz(mxro,maxip),
     &       area(mxro),ss1(mxro,maxip),ss2(mxro,maxip),
     &       vnx(mxro),vny(mxro),vnz(mxro),Vinf(mxro)
c
      common gamma(mxro),circ(maxro),carga(mxro),theta(1)  
      common ciex(mxro,maxir),ciey(mxro,maxir),ciez(mxro,maxir),
     &       cix1tmp(mxro*mxro),ciy1tmp(mxro*mxro),ciz1tmp(mxro*mxro),
     &       cix2tmp(mxro*mxro),ciy2tmp(mxro*mxro),ciz2tmp(mxro*mxro)
      common vix(mxro,maxip),viy(mxro,maxip),viz(mxro,maxip),
     &       vi(mxro,maxip),vtgx(mxro,maxip),vtgy(mxro,maxip),
     &       urx(mxro,maxip),ury(mxro,maxip),urz(mxro,maxip)     
      common urex(mxro),urey(mxro),urez(mxro),
     &       urix(mxro),uriy(mxro),uriz(mxro)
c
      common U,UU,omega,c0,a,rh,rt,oi,of,pf,ch,ct,zlim,factor1,factor2
      common pi,beta,cero,signo,redvel,coefa,hc,dfi,alfac,c1,c2,distan
      common indice,index0,index1,index2,index3,index4,index5,index6,      
     &       index7,index8,index9,index10,index11,index12,alfac0      
      common npan,nodos,ncapa,npal,npaso,nr,no,np,nk,kult,inic,in1,in2, 
     &       in3,nsubr,nsld2
c
      character integ1(maxro)*150,integ2(maxro)*150,gamastr(maxro)*70,
     &          circostr(maxro)*70,salida2out(102)*95
c     Variable para internal file del archivo global subr.out
c     el cual lleva los mismos datos que la salida standar
      character subrout(500)*60
c                      
                      
      common integ1,integ2,gamastr,circostr,subrout,salida2out
c
c<
c.......................................................................
c                 
      U12=U**2
c 
      if(index2.eq.0) dofi = of-oi
      if(index2.ne.0) dofi = 1.d0
c
      kio=1
      kkk=1
c                   
c     U22   --->  relativo a las condiciones locales (Gould & Fiddes)
c
      do 101 npa=1,npan                                                                  
c     
      vlocal2=urx(npa,ncapa)**2+ury(npa,ncapa)**2+urz(npa,ncapa)**2  
      U22=UU**2+vtgx(npa,ncapa)**2+vtgy(npa,ncapa)**2
      ss1(npa,ncapa)= vlocal2/U12                    
      ss2(npa,ncapa)= vlocal2/U22 
c
      write(27,102) npa,pcx(npa,1)/rt,(o(kkk)+(o(kkk+1)-o(kkk))/4.)/dofi
     &             ,1.d0-ss1(npa,ncapa),1.d0-ss2(npa,ncapa)
c
      write(25,100) ncapa,npa,
     &              pcx(npa,ncapa),pcy(npa,ncapa),pcz(npa,ncapa),
     &              1.d0-ss1(npa,ncapa),1.d0-ss2(npa,ncapa)
c                
      kio=kio+1
      if(kio.gt.nr) kio=1
      if(kio.eq.1)  kkk=kkk+1
c
  101 continue                    
  103 continue
  102 format(2x,i5,4(2x,f9.5))
  100 format(1x,2(1x,i4),3(1x,f9.6),2(1x,f12.6))
c
c.......................................................................
c
c     representacion por Tecplot de coeficientes de presion (Pres.PLT)
c   
c     grafico distribuciones Cp   (sobre la pala)
c
      if(indice.eq.1) write(12,201)indice
  201 format(1x,'TITLE = "COEFICIENTES DE PRESION Cp = 1-S ',
     &          '(',i1,')"')
c
      if(indice.eq.1) write(12,202)
  202 format(1x,'Variables = "x", "y", "z", "Cp1", "Cp2" ')
c
      if(indice.eq.1) write(12,203)nr,no
  203 format(1x,/,1x,'Zone T="  I,Cps", I=',i6,', J=',i5,
     &               ', K=1, F=POINT') 
c
      do 125 io=1,no
      do 126 ir=1,nr
c      
      npa=ir+(io-1)*nr
c                           
      write(12,41) pcx(npa,ncapa),pcy(npa,ncapa),pcz(npa,ncapa),
     &             1.d0-ss1(npa,ncapa),1.d0-ss2(npa,ncapa) 
c 
  126 continue
  125 continue
   41 format(2x,5(1x,f11.6))                
c
      write(12,23)
   23 format(2x)
c
c     conectividades					NO NECESARIO PARA FPOINT  
c                     
c.......................................................................
c                    
      mo=1         
      if(no.gt.20)mo=2
      do 10 ir=1,nr      
      write(37,11) pcx(ir,ncapa)/rt,
     &             (1.d0-ss1(ir+(io-1)*nr,ncapa),io=1,no,mo)
      write(38,11) pcx(ir,ncapa)/rt,
     &             (1.d0-ss2(ir+(io-1)*nr,ncapa),io=1,no,mo)
   10 continue
   11 format(1x,f7.4,20(1x,f9.5))
c
      return
      end                                                              
c      
c-----------------------------------------------------------------------
c 
      subroutine presion2
c
c     distribucion de presiones sobre los puntos @ 3c/4 extrapolados 
c     para extrados (ncapa = 10) e intrados (ncapa = 11)
c     (Indice = 3)
c
c     Coefp = (Plocal-Pinf)/(0.5*densidad*Uinf^2) = 1 - S
c           
c     S = (Vlocal/Uinf)^2           
c
c.......................................................................
c>
      implicit real*8 (a-h,o-z)
c
      parameter (maxir=51,maxio=51,maxip=11,maxnk=2001,
     &          mxir=maxir-1,mxio=maxio-1,mxip=maxip-1,
     &          maxro=maxir*maxio,mxro=mxir*mxio,mxnk=maxnk-1)
c
      common r(maxir),o(maxio),chord(maxir),yarc(maxir,maxio)
      common px(maxro),py(maxro),pz(maxro)
      common xbf(maxir),ybf(maxir),zbf(maxir),rbf(maxir)
      common xe(maxir,maxnk),ye(maxir,maxnk),ze(maxir,maxnk),
     &       re(maxir,maxnk),fi(maxir,maxnk),fifa(mxro,5),fipri(mxro,5)
c     
      common p1x(mxro),p1y(mxro),p1z(mxro),      
     &       p2x(mxro),p2y(mxro),p2z(mxro),
     &       p3x(mxro),p3y(mxro),p3z(mxro),
     &       p4x(mxro),p4y(mxro),p4z(mxro),
     &       pax(mxro),pay(mxro),paz(mxro),
     &       pbx(mxro),pby(mxro),pbz(mxro)
c
      common pcx(mxro,maxip),pcy(mxro,maxip),pcz(mxro,maxip),
     &       area(mxro),ss1(mxro,maxip),ss2(mxro,maxip),
     &       vnx(mxro),vny(mxro),vnz(mxro),Vinf(mxro)
c
      common gamma(mxro),circ(maxro),carga(mxro),theta(1)  
      common ciex(mxro,maxir),ciey(mxro,maxir),ciez(mxro,maxir),
     &       cix1tmp(mxro*mxro),ciy1tmp(mxro*mxro),ciz1tmp(mxro*mxro),
     &       cix2tmp(mxro*mxro),ciy2tmp(mxro*mxro),ciz2tmp(mxro*mxro)
      common vix(mxro,maxip),viy(mxro,maxip),viz(mxro,maxip),
     &       vi(mxro,maxip),vtgx(mxro,maxip),vtgy(mxro,maxip),
     &       urx(mxro,maxip),ury(mxro,maxip),urz(mxro,maxip)     
      common urex(mxro),urey(mxro),urez(mxro),
     &       urix(mxro),uriy(mxro),uriz(mxro)
c
      common U,UU,omega,c0,a,rh,rt,oi,of,pf,ch,ct,zlim,factor1,factor2
      common pi,beta,cero,signo,redvel,coefa,hc,dfi,alfac,c1,c2,distan
      common indice,index0,index1,index2,index3,index4,index5,index6,      
     &       index7,index8,index9,index10,index11,index12,alfac0      
      common npan,nodos,ncapa,npal,npaso,nr,no,np,nk,kult,inic,in1,in2, 
     &       in3,nsubr,nsld2
c
      character integ1(maxro)*150,integ2(maxro)*150,gamastr(maxro)*70,
     &          circostr(maxro)*70,salida2out(102)*95
c     Variable para internal file del archivo global subr.out
c     el cual lleva los mismos datos que la salida standar
      character subrout(500)*60
c                      
                      
      common integ1,integ2,gamastr,circostr,subrout,salida2out
c
c<
c.......................................................................
c                 
      U12 = U**2
c                   
c     U22   --->  relativo a las condiciones locales (Gould & Fiddes)
c
      do 101 npa=1,npan                                                                  
c     
      vlocal2 = urx(npa,ncapa)**2+ury(npa,ncapa)**2+urz(npa,ncapa)**2  
          U22 = UU**2+vtgx(npa,ncapa)**2+vtgy(npa,ncapa)**2
      ss1(npa,ncapa) = vlocal2/U12                    
      ss2(npa,ncapa) = vlocal2/U22 
c
      if(ncapa.eq.11) write(61,100) npa,
     &                              pcx(npa,1),pcy(npa,1),pcz(npa,1),
     &                              1.d0-ss1(npa,10),1.d0-ss2(npa,10),
     &                              1.d0-ss1(npa,11),1.d0-ss2(npa,11)
c
  101 continue                    
  100 format(2x,i4,3(1x,f9.6),4(1x,f14.7))
c
c.......................................................................
c
	if(ncapa.le.10) goto 12
c
c     representacion por Tecplot de coeficientes de presion (Pres.PLT)
c   
c     grafico distribuciones Cp (sobre extrados e intrados de la pala)
c
       write(62,201)indice
  201 format(1x,'TITLE = "COEFICIENTES DE PRESION Cp = 1-S p/E & I ',
     &          '(',i1,')"')
c
       write(62,202)
  202 format
     &(1x,'Variables = "x", "y", "z", "Cp1e", "Cp2e", "Cp1i", "Cp2i" ')
c
       write(62,204)nr,no
  204 format(1x,/,1x,'Zone T=" II,Cps E & I", I=',i6,', J=',i5,
     &               ', K=1, F=POINT') 
c
      do 125 io = 1,no
      do 126 ir = 1,nr
c      
            npa = ir+(io-1)*nr
c                           
      write(62,41) pcx(npa,1),pcy(npa,1),pcz(npa,1),
     &             1.d0-ss1(npa,10),1.d0-ss2(npa,10), 
     &             1.d0-ss1(npa,11),1.d0-ss2(npa,11) 
c 
  126 continue
  125 continue
   41 format(2x,7(1x,f11.6))                
c
      write(62,23)
   23 format(2x)
c
c     conectividades					NO NECESARIO PARA FPOINT  
c                     
   12 continue
c
c.......................................................................
c
      return
      end                                                              
c      
c-----------------------------------------------------------------------
c 
      subroutine cargas
c
c     calculo de las fuerzas sobre cada panel y sobre la pala, por 
c     aplicacion del teorema de Kutta-Joukovski
c
c	Punto de calculo @ c/4 (i.e., Indice = 2, ncapa = 10, index11 = 0)
c
c     {F}/ro = -(V}.Circ.{dl}    
c                                                             
c       Cf = 2[{F}/ro]/(U^2.A)
c                                                             
c       Cq = 2[{Fxd}/ro]/(U^2.A.R)
c                                                             
c     Cpot = 2[{Fxd}.{0,0,w}/ro]/(U^3.A)
c                  
c.......................................................................
c>
      implicit real*8 (a-h,o-z)
c
      parameter (maxir=51,maxio=51,maxip=11,maxnk=2001,
     &          mxir=maxir-1,mxio=maxio-1,mxip=maxip-1,
     &          maxro=maxir*maxio,mxro=mxir*mxio,mxnk=maxnk-1)
c
      common r(maxir),o(maxio),chord(maxir),yarc(maxir,maxio)
      common px(maxro),py(maxro),pz(maxro)
      common xbf(maxir),ybf(maxir),zbf(maxir),rbf(maxir)
      common xe(maxir,maxnk),ye(maxir,maxnk),ze(maxir,maxnk),
     &       re(maxir,maxnk),fi(maxir,maxnk),fifa(mxro,5),fipri(mxro,5)
c     
      common p1x(mxro),p1y(mxro),p1z(mxro),      
     &       p2x(mxro),p2y(mxro),p2z(mxro),
     &       p3x(mxro),p3y(mxro),p3z(mxro),
     &       p4x(mxro),p4y(mxro),p4z(mxro),
     &       pax(mxro),pay(mxro),paz(mxro),
     &       pbx(mxro),pby(mxro),pbz(mxro)
c
      common pcx(mxro,maxip),pcy(mxro,maxip),pcz(mxro,maxip),
     &       area(mxro),ss1(mxro,maxip),ss2(mxro,maxip),
     &       vnx(mxro),vny(mxro),vnz(mxro),Vinf(mxro)
c
      common gamma(mxro),circ(maxro),carga(mxro),theta(1)  
      common ciex(mxro,maxir),ciey(mxro,maxir),ciez(mxro,maxir),
     &       cix1tmp(mxro*mxro),ciy1tmp(mxro*mxro),ciz1tmp(mxro*mxro),
     &       cix2tmp(mxro*mxro),ciy2tmp(mxro*mxro),ciz2tmp(mxro*mxro)
      common vix(mxro,maxip),viy(mxro,maxip),viz(mxro,maxip),
     &       vi(mxro,maxip),vtgx(mxro,maxip),vtgy(mxro,maxip),
     &       urx(mxro,maxip),ury(mxro,maxip),urz(mxro,maxip)     
      common urex(mxro),urey(mxro),urez(mxro),
     &       urix(mxro),uriy(mxro),uriz(mxro)
c
      common U,UU,omega,c0,a,rh,rt,oi,of,pf,ch,ct,zlim,factor1,factor2
      common pi,beta,cero,signo,redvel,coefa,hc,dfi,alfac,c1,c2,distan
      common indice,index0,index1,index2,index3,index4,index5,index6,      
     &       index7,index8,index9,index10,index11,index12,alfac0      
      common npan,nodos,ncapa,npal,npaso,nr,no,np,nk,kult,inic,in1,in2, 
     &       in3,nsubr,nsld2
c
      character integ1(maxro)*150,integ2(maxro)*150,gamastr(maxro)*70,
     &          circostr(maxro)*70,salida2out(102)*95
c     Variable para internal file del archivo global subr.out
c     el cual lleva los mismos datos que la salida standar
      character subrout(500)*60
c                      
                      
      common integ1,integ2,gamastr,circostr,subrout,salida2out
c
c<
c.......................................................................
c    
      dimension fzax(mxro),fzay(mxro),fzaz(mxro)                 
c.......................................................................
c                
c    densidad del aire = 1,2 kg/m3
c
      denso = 1.2   
c
      adisco = pi*rt**2                   
c
      cfx = cero
      cfy = cero
      cfz = cero
      cqx = cero
      cqy = cero
      cqz = cero
c
      apala=cero           
c
      do 101 npa=1,npan                                                                  
c                        
      apala = apala+area(npa)
c
      vinfx =-omega*pcy(npa,10)+vix(npa,10)  
      vinfy = omega*pcx(npa,10)+viy(npa,10) 
      vinfz =                UU+viz(npa,10)
c                          
      dabx = pbx(npa)-pax(npa)
      daby = pby(npa)-pay(npa)
      dabz = pbz(npa)-paz(npa)
c                             
      fzax(npa) = -(vinfy*dabz-vinfz*daby)*circ(npa)*denso
      fzay(npa) = -(vinfz*dabx-vinfx*dabz)*circ(npa)*denso
      fzaz(npa) = -(vinfx*daby-vinfy*dabx)*circ(npa)*denso
c
      fza2 = fzax(npa)**2+fzay(npa)**2+fzaz(npa)**2 
      fza  = dsqrt(fza2)     
c
      vinf2= vinfz**2+vinfy**2+vinfx**2
      Vinf(npa) = dsqrt(vinf2)      
c                   
      dlong2=(pbx(npa)-pax(npa))**2+
     &       (pby(npa)-pay(npa))**2+
     &       (pbz(npa)-paz(npa))**2
      dlong =dsqrt(dlong2) 
c     
      cfx = cfx+fzax(npa)
      cfy = cfy+fzay(npa)
      cfz = cfz+fzaz(npa)
c                        
c     {Q} = (F}x{d}             {d} = -{r}
c
      cqx = cqx-fzay(npa)*pcz(npa,10)+fzaz(npa)*pcy(npa,10)
      cqy = cqy-fzaz(npa)*pcx(npa,10)+fzax(npa)*pcz(npa,10)
      cqz = cqz-fzax(npa)*pcy(npa,10)+fzay(npa)*pcx(npa,10)
c
      write(48,102) npa,vinfx/U,vinfy/U,vinfz/U,vinf(npa)/U,
     &              dlong/rt,fzax(npa),fzay(npa),fzaz(npa),fza
c                
  101 continue                    
  102 format(2x,i5,9(2x,f9.5))
c
      denom1= apala*denso*U**2       
      denom2=adisco*denso*U**2       
c                                    
c     Pot = {Q}.{w}       {w} = -w.{0,0,1} = -w.k  (W pala = - W aire)
c
      wpala = (-1.)*omega                   
c
      cfx1 = 2.*cfx/denom1
      cfy1 = 2.*cfy/denom1
      cfz1 = 2.*cfz/denom1       
      cpot1= 2.*cqz*wpala/(denom1*U)
      cqx1 = 2.*cqx/(denom1*rt)
      cqy1 = 2.*cqy/(denom1*rt)
      cqz1 = 2.*cqz/(denom1*rt)
c
      cfx2 = 2.*cfx/denom2
      cfy2 = 2.*cfy/denom2
      cfz2 = 2.*cfz/denom2
      cpot2= 2.*cqz*wpala/(denom2*U)
      cqx2 = 2.*cqx/(denom2*rt)
      cqy2 = 2.*cqy/(denom2*rt)
      cqz2 = 2.*cqz/(denom2*rt)
c
      write(salida2out(nsld2),'(a1)') ""
      write(salida2out(nsld2+1),103)cfx1,cfy1,cfz1
      write(salida2out(nsld2+2),1031)cqx1,cqy1,cqz1
      write(salida2out(nsld2+3),1032)cpot1
      write(salida2out(nsld2+4),'(a1)') ""
      nsld2=nsld2+5
  103 format(4x,'Cfx1 =',f11.5,4x,'Cfy1 =',f11.5,4x,'Cfz1 =',f11.5)
 1031 format(4x,'Cqx1 =',f11.5,4x,'Cqy1 =',f11.5,4x,'Cqz1 =',f11.5)
 1032 format(3x,'Cpot1 =',f11.5)
!      write(50,103)cfx1,cfy1,cfz1,cqx1,cqy1,cqz1,cpot1
!  103 format(1x,/,4x,'Cfx1 =',f11.5,4x,'Cfy1 =',f11.5,4x,'Cfz1 =',f11.5,
!     &          /,4x,'Cqx1 =',f11.5,4x,'Cqy1 =',f11.5,4x,'Cqz1 =',f11.5,
!     &          /,3x,'Cpot1 =',f11.5,/)
c
      write(salida2out(nsld2),'(a1)') ""
      write(salida2out(nsld2+1),104)cfx2,cfy2,cfz2
      write(salida2out(nsld2+2),1041)cqx2,cqy2,cqz2
      write(salida2out(nsld2+3),1042)cpot2
      write(salida2out(nsld2+4),'(a1)') ""
      nsld2=nsld2+5
  104 format(4x,'Cfx2 =',f11.5,4x,'Cfy2 =',f11.5,4x,'Cfz2 =',f11.5)
 1041 format(4x,'Cqx2 =',f11.5,4x,'Cqy2 =',f11.5,4x,'Cqz2 =',f11.5)
 1042 format(3x,'Cpot2 =',f11.5)
!      write(50,104)cfx2,cfy2,cfz2,cqx2,cqy2,cqz2,cpot2
!  104 format(1x,/,4x,'Cfx2 =',f11.5,4x,'Cfy2 =',f11.5,4x,'Cfz2 =',f11.5,
!     &          /,4x,'Cqx2 =',f11.5,4x,'Cqy2 =',f11.5,4x,'Cqz2 =',f11.5,
!     &          /,3x,'Cpot2 =',f11.5,/)
c
c    representacion por Tecplot de Fuerzas (fuerza.PLT)
c
      write(49,1)indice
      write(99,1)indice
    1 format(1x,'TITLE = "PANELES y FUERZAS RESULTANTES ADIMENS.',
     &          '(',i1,')"')
c
      write(49,2)
      write(99,9876)
    2 format(1x,'Variables = "x", "y", "z", "Cfx", "Cfy", "Cfz" ')
 9876 format(1x,'Variables = "x", "y", "z", "Cfx", "Cfy", "Cfz",',
     &       '"Vix/U", "Viy/U", "Viz/U", "Vrx/U", "Vry/U", "Vrz/U" ')
c
      write(49,3)5*npan,npan
      write(99,3)4*npan,npan
    3 format(1x,/,1x,'Zone T=" I, malla", N=',i6,', E=',i5,
     &               ', F=FEPOINT, ET=QUADRILATERAL') 
c
      do 25 io=1,no
      do 26 ir=1,nr
c      
      npa=ir+(io-1)*nr
c
      write(99,40) p1x(npa),p1y(npa),p1z(npa),cero,cero,cero
     &  	                    ,cero,cero,cero,cero,cero,cero
      write(99,40) p2x(npa),p2y(npa),p2z(npa),cero,cero,cero
     &  	                    ,cero,cero,cero,cero,cero,cero
      write(99,40) p3x(npa),p3y(npa),p3z(npa),cero,cero,cero
     &  	                    ,cero,cero,cero,cero,cero,cero
      write(99,40) p4x(npa),p4y(npa),p4z(npa),cero,cero,cero
     &  	                    ,cero,cero,cero,cero,cero,cero
      write(49,40) p1x(npa),p1y(npa),p1z(npa),cero,cero,cero
      write(49,40) p2x(npa),p2y(npa),p2z(npa),cero,cero,cero
      write(49,40) p3x(npa),p3y(npa),p3z(npa),cero,cero,cero
      write(49,40) p4x(npa),p4y(npa),p4z(npa),cero,cero,cero               
      write(49,40) pcx(npa,10),pcy(npa,10),pcz(npa,10),
     &             fzax(npa),fzay(npa),fzaz(npa) 
c   
   26 continue
   25 continue
c
      write(49,23)
      write(99,23)
c
c     conectividades
c
      do 45 k=1,npan
c                 
      nn=1+5*(k-1)
c      
      n1=nn
      n2=nn+1
      n3=nn+2
      n4=nn+3
c
      write(49,27)n1,n2,n3,n4 
c
      nnn=1+4*(k-1)
c      
      nn1=nnn
      nn2=nnn+1
      nn3=nnn+2
      nn4=nnn+3
c
      write(99,27)nn1,nn2,nn3,nn4 
c      
   45 continue              
c
      nptos = npan
	nelem = (nr-1)*(no-1)
c
      write(99,93) nptos,nelem
   93 format(1x,/,1x,'Zone T=" II,Fza", N=',i5,', E=',i5,
     &               ', F=FEPOINT, ET=QUADRILATERAL') 
c
      do 75 io=1,no
      do 76 ir=1,nr
c      
      npa=ir+(io-1)*nr
c
      write(99,40) pcx(npa,10),pcy(npa,10),pcz(npa,10),
     &             fzax(npa),fzay(npa),fzaz(npa),
     &			 vix(npa,ncapa)/U,viy(npa,ncapa)/U,viz(npa,ncapa)/U,
     &             urx(npa,ncapa)/U,ury(npa,ncapa)/U,urz(npa,ncapa)/U 
c   
   76 continue
   75 continue
c
      write(99,23)
      do 94 kr=1,nr-1
      do 95 ko=1,no-1
c                 
      nnm=ko+(nr-1)*(kr-1)
c      
      nm1=nnm
      nm2=nnm+1
      nm3=nnm+nr
      nm4=nnm+nr+1
c
      write(99,27)nm1,nm2,nm3,nm4 
c
   95 continue
   94 continue
c
   27 format(1x,4(1x,i7)) 
   23 format(2x)
   40 format(1x,12(1x,f11.6)) 
c
      return
      end                                                              
c      
c-----------------------------------------------------------------------
c
      subroutine ploteo1
c
c    representacion por Tecplot de VELOCIDADES INDUCIDAS ADIM.(PLT1.PLT)
c
c.......................................................................
c>
      implicit real*8 (a-h,o-z)
c
      parameter (maxir=51,maxio=51,maxip=11,maxnk=2001,
     &          mxir=maxir-1,mxio=maxio-1,mxip=maxip-1,
     &          maxro=maxir*maxio,mxro=mxir*mxio,mxnk=maxnk-1)
c
      common r(maxir),o(maxio),chord(maxir),yarc(maxir,maxio)
      common px(maxro),py(maxro),pz(maxro)
      common xbf(maxir),ybf(maxir),zbf(maxir),rbf(maxir)
      common xe(maxir,maxnk),ye(maxir,maxnk),ze(maxir,maxnk),
     &       re(maxir,maxnk),fi(maxir,maxnk),fifa(mxro,5),fipri(mxro,5)
c     
      common p1x(mxro),p1y(mxro),p1z(mxro),      
     &       p2x(mxro),p2y(mxro),p2z(mxro),
     &       p3x(mxro),p3y(mxro),p3z(mxro),
     &       p4x(mxro),p4y(mxro),p4z(mxro),
     &       pax(mxro),pay(mxro),paz(mxro),
     &       pbx(mxro),pby(mxro),pbz(mxro)
c
      common pcx(mxro,maxip),pcy(mxro,maxip),pcz(mxro,maxip),
     &       area(mxro),ss1(mxro,maxip),ss2(mxro,maxip),
     &       vnx(mxro),vny(mxro),vnz(mxro),Vinf(mxro)
c
      common gamma(mxro),circ(maxro),carga(mxro),theta(1)  
      common ciex(mxro,maxir),ciey(mxro,maxir),ciez(mxro,maxir),
     &       cix1tmp(mxro*mxro),ciy1tmp(mxro*mxro),ciz1tmp(mxro*mxro),
     &       cix2tmp(mxro*mxro),ciy2tmp(mxro*mxro),ciz2tmp(mxro*mxro)
      common vix(mxro,maxip),viy(mxro,maxip),viz(mxro,maxip),
     &       vi(mxro,maxip),vtgx(mxro,maxip),vtgy(mxro,maxip),
     &       urx(mxro,maxip),ury(mxro,maxip),urz(mxro,maxip)     
      common urex(mxro),urey(mxro),urez(mxro),
     &       urix(mxro),uriy(mxro),uriz(mxro)
c
      common U,UU,omega,c0,a,rh,rt,oi,of,pf,ch,ct,zlim,factor1,factor2
      common pi,beta,cero,signo,redvel,coefa,hc,dfi,alfac,c1,c2,distan
      common indice,index0,index1,index2,index3,index4,index5,index6,      
     &       index7,index8,index9,index10,index11,index12,alfac0      
      common npan,nodos,ncapa,npal,npaso,nr,no,np,nk,kult,inic,in1,in2, 
     &       in3,nsubr,nsld2
c
      character integ1(maxro)*150,integ2(maxro)*150,gamastr(maxro)*70,
     &          circostr(maxro)*70,salida2out(102)*95
c     Variable para internal file del archivo global subr.out
c     el cual lleva los mismos datos que la salida standar
      character subrout(500)*60
c                      
                      
      common integ1,integ2,gamastr,circostr,subrout,salida2out
c
c<
c.......................................................................
c    
c     sobre y alrededor de la pala No.1 (ib=1)
c
      if(index3.eq.0.and.ncapa.gt.2) goto 5
      if(index3.ne.0.and.ncapa.gt.1) goto 5
c
      if(indice.eq.1) write(23,1)indice
    1 format(1x,'TITLE = "PANELES y VELOCIDADES INDUCIDAS ADIMENS.',
     &          '(',i1,')"')
c
      if(indice.eq.1) write(23,2)
    2 format(1x,'Variables = "x", "y", "z", "Vix*", "Viy*", "Viz*" ')
c
      if(indice.eq.1) write(23,3)5*npan,npan
      if(indice.eq.2) write(23,6)5*npan,npan
    3 format(1x,'Zone T=" I,Vi", N=',i6,', E=',i5,
     &          ', F=FEPOINT, ET=QUADRILATERAL') 
    6 format(1x,'Zone T="II,Vi", N=',i6,', E=',i5,
     &          ', F=FEPOINT, ET=QUADRILATERAL') 
c                          
    5 continue
      if(indice.eq.3) write(23,4)ncapa,5*npan,npan
    4 format(1x,'Zone T="',i2,',Vi", N=',i6,', E=',i5,
     &          ', F=FEPOINT, ET=QUADRILATERAL') 
c
      do 25 io=1,no
      do 26 ir=1,nr
c      
      npa=ir+(io-1)*nr
c
      write(23,40) p1x(npa),p1y(npa),p1z(npa),cero,cero,cero
      write(23,40) p2x(npa),p2y(npa),p2z(npa),cero,cero,cero
      write(23,40) p3x(npa),p3y(npa),p3z(npa),cero,cero,cero
      write(23,40) p4x(npa),p4y(npa),p4z(npa),cero,cero,cero               
      write(23,40) pcx(npa,ncapa),pcy(npa,ncapa),pcz(npa,ncapa),
     &             vix(npa,ncapa)/U,viy(npa,ncapa)/U,viz(npa,ncapa)/U  
c                            
   26 continue
   25 continue
c
      write(23,23)
c
c       conectividades  
c
      do 45 k=1,npan
c                 
      nn=1+5*(k-1)
c      
      n1=nn
      n2=nn+1
      n3=nn+2
      n4=nn+3
c
      write(23,27)n1,n2,n3,n4
c      
   45 continue              
c
   27 format(1x,4(1x,i7)) 
   23 format(2x)
   40 format(1x,6(1x,f11.6)) 
c
      return
      end
c
c-----------------------------------------------------------------------
c
      subroutine ploteo2
c
c    representacion por Tecplot de VELOCIDADES RESULTANTES ADIM.(PLT2.PLT)
c
c.......................................................................
c>
      implicit real*8 (a-h,o-z)
c
      parameter (maxir=51,maxio=51,maxip=11,maxnk=2001,
     &          mxir=maxir-1,mxio=maxio-1,mxip=maxip-1,
     &          maxro=maxir*maxio,mxro=mxir*mxio,mxnk=maxnk-1)
c
      common r(maxir),o(maxio),chord(maxir),yarc(maxir,maxio)
      common px(maxro),py(maxro),pz(maxro)
      common xbf(maxir),ybf(maxir),zbf(maxir),rbf(maxir)
      common xe(maxir,maxnk),ye(maxir,maxnk),ze(maxir,maxnk),
     &       re(maxir,maxnk),fi(maxir,maxnk),fifa(mxro,5),fipri(mxro,5)
c     
      common p1x(mxro),p1y(mxro),p1z(mxro),      
     &       p2x(mxro),p2y(mxro),p2z(mxro),
     &       p3x(mxro),p3y(mxro),p3z(mxro),
     &       p4x(mxro),p4y(mxro),p4z(mxro),
     &       pax(mxro),pay(mxro),paz(mxro),
     &       pbx(mxro),pby(mxro),pbz(mxro)
c
      common pcx(mxro,maxip),pcy(mxro,maxip),pcz(mxro,maxip),
     &       area(mxro),ss1(mxro,maxip),ss2(mxro,maxip),
     &       vnx(mxro),vny(mxro),vnz(mxro),Vinf(mxro)
c
      common gamma(mxro),circ(maxro),carga(mxro),theta(1)  
      common ciex(mxro,maxir),ciey(mxro,maxir),ciez(mxro,maxir),
     &       cix1tmp(mxro*mxro),ciy1tmp(mxro*mxro),ciz1tmp(mxro*mxro),
     &       cix2tmp(mxro*mxro),ciy2tmp(mxro*mxro),ciz2tmp(mxro*mxro)
      common vix(mxro,maxip),viy(mxro,maxip),viz(mxro,maxip),
     &       vi(mxro,maxip),vtgx(mxro,maxip),vtgy(mxro,maxip),
     &       urx(mxro,maxip),ury(mxro,maxip),urz(mxro,maxip)     
      common urex(mxro),urey(mxro),urez(mxro),
     &       urix(mxro),uriy(mxro),uriz(mxro)
c
      common U,UU,omega,c0,a,rh,rt,oi,of,pf,ch,ct,zlim,factor1,factor2
      common pi,beta,cero,signo,redvel,coefa,hc,dfi,alfac,c1,c2,distan
      common indice,index0,index1,index2,index3,index4,index5,index6,      
     &       index7,index8,index9,index10,index11,index12,alfac0      
      common npan,nodos,ncapa,npal,npaso,nr,no,np,nk,kult,inic,in1,in2, 
     &       in3,nsubr,nsld2
c
      character integ1(maxro)*150,integ2(maxro)*150,gamastr(maxro)*70,
     &          circostr(maxro)*70,salida2out(102)*95
c     Variable para internal file del archivo global subr.out
c     el cual lleva los mismos datos que la salida standar
      character subrout(500)*60
c                      
                      
      common integ1,integ2,gamastr,circostr,subrout,salida2out
c
c<
c.......................................................................
c
c     sobre y alrededor de la pala No.1 (ib=1)
c
      if(index3.eq.0.and.ncapa.gt.2) goto 5
      if(index3.ne.0.and.ncapa.gt.1) goto 5
c
      if(indice.eq.1) write(24,1)indice
    1 format(1x,'TITLE = "PANELES y VELOCIDADES RESULTANTES ADIMENS.',
     &          '(',i1,')"')
c
      if(indice.eq.1) write(24,2)
    2 format(1x,'Variables = "x", "y", "z", "Urx*", "Ury*", "Urz*" ')
c
      if(indice.eq.1) write(24,3)5*npan,npan
    3 format(1x,/,1x,'Zone T=" I,Ur", N=',i6,', E=',i5,
     &               ', F=FEPOINT, ET=QUADRILATERAL') 
c
      if(indice.eq.2) write(24,6)5*npan,npan
    6 format(1x,/,1x,'Zone T="II,Ur", N=',i6,', E=',i5,
     &               ', F=FEPOINT, ET=QUADRILATERAL') 
c                          
    5 continue
      if(indice.eq.3) write(24,4)ncapa,5*npan,npan
    4 format(1x,/,1x,'Zone T="',i2,',Ur", N=',i6,', E=',i5,
     &               ', F=FEPOINT, ET=QUADRILATERAL') 
c
      do 25 io=1,no
      do 26 ir=1,nr
c      
      npa=ir+(io-1)*nr
c
      write(24,40) p1x(npa),p1y(npa),p1z(npa),cero,cero,cero
      write(24,40) p2x(npa),p2y(npa),p2z(npa),cero,cero,cero
      write(24,40) p3x(npa),p3y(npa),p3z(npa),cero,cero,cero
      write(24,40) p4x(npa),p4y(npa),p4z(npa),cero,cero,cero               
      write(24,40) pcx(npa,ncapa),pcy(npa,ncapa),pcz(npa,ncapa),
     &             urx(npa,ncapa)/U,ury(npa,ncapa)/U,urz(npa,ncapa)/U  
c             
   26 continue
   25 continue
c
      write(24,23)
c
c     conectividades  
c
      do 45 k=1,npan
c                 
      nn=1+5*(k-1)
c      
      n1=nn
      n2=nn+1
      n3=nn+2
      n4=nn+3
c
      write(24,27)n1,n2,n3,n4 
c      
   45 continue              
c
   27 format(1x,4(1x,i7)) 
   23 format(2x)
   40 format(1x,6(1x,f11.6)) 
c
      return
      end
c
c-----------------------------------------------------------------------
c
      subroutine circo(nb,nc,circo_str,tamanio)
c                                                                       
c     reformulacion archivo circo.txt
c                   p/circulacion adimensional vs r/R,  cr.txt
c                   p/circulacion adimensional vs o/c,  co.txt
c
      parameter (maxir=51,maxio=51)
c
      dimension rr(maxio,maxir),gg(maxio,maxir),oo(maxio,maxir)
      integer tamanio
      character circo_str(tamanio)*70
c
!      open(unit=28,file='circo.txt')      
      open(unit=29,file='cr.txt')
      open(unit=30,file='co.txt')
c            
      kkont=1
      do 14 k = 1,nc+1
      do 15 l = 1,nb
c      
      read(circo_str(kkont),13) rr(k,l),gg(k,l),oo(k,l)
      kkont=kkont+1
!      read(28,13) rr(k,l),gg(k,l),oo(k,l)
   13 format(6x,f9.4,14x,f10.6,f10.6) 
c     
   15 continue
   14 continue
c
      mc=1
      mb=1
      if(nc.gt.20)mc=2   
      if(nb.gt.20)mb=2   
      if(nc.gt.40)mc=3   
      if(nb.gt.40)mb=3   
c
c     distribucion segun envergadura
c
      do 16 l = 1,nb
      write(29,17) rr(1,l),(gg(k,l),k = 1,nc,mc),gg(nc+1,l)
   16 continue
   17 format(1x,f7.4,21(1x,f8.4))
c
c     distribucion segun cuerda    
c              
      do 6 i = 1,nc+1
      write(30,7) oo(i,1),(gg(i,j),j = 1,nb,mb)
    6 continue
    7 format(1x,f7.4,20(1x,f8.4))
c              
!      close(28)
      close(29)
      close(30)
c      
      return
      end
c
c-----------------------------------------------------------------------
c
      subroutine gammas(nb,nc,gama_str,tamanio)
c                                                                       
c    Circulacion asociada a cada anillo vorticoso y a la estela 
c               gr:  p/circulacion adimensional vs r/R)
c               go:  p/circulacion adimensional vs o/c)
c
      parameter (maxir=51,maxio=51)
c
      dimension rr(maxio,maxir),gg(maxio,maxir),oo(maxio,maxir),
     &          dgg(maxio,maxir)
c
      integer tamanio
      character gama_str(tamanio)*70
!
!      open(unit=16,file='gama.txt')      
      open(unit=31,file='gr.out')
      open(unit=32,file='go.out')
      open(unit=63,file='gdifr.out')
      open(unit=64,file='gdifo.out')
c     
      cero = 0.0d0
      uno = 1.0d0
      kont=1
c
      do 14 k = 1,nc
      do 15 l = 1,nb
c      
      read(gama_str(kont),13) rr(k,l),gg(k,l),oo(k,l)
      kont=kont+1
   13 format(15x,f8.4,16x,f14.8,1x,f8.4) 
c
   15 continue
   14 continue
c
      do 11 k = 1,nc
      do 12 l = 1,nb
      if(k.eq.1) dgg(k,l)= gg(k,l)
      if(k.gt.1) dgg(k,l)= gg(k,l)-gg(k-1,l)
   12 continue
   11 continue
c
      mc=1
      mb=1
c     if(nc.gt.30)mc=2   
c     if(nb.gt.30)mb=2   
c     if(nc.gt.40)mc=3   
c     if(nb.gt.40)mb=3   
c     
c     distribucion segun envergadura
c            
      do 16 l = 1,nb
      write(31,17) rr(1,l), (gg(k,l),k = 1,nc,mc)
   16 continue
   17 format(1x,f7.4,30(1x,f9.5))
c
c            
      do 26 l = 1,nb
      write(63,27) rr(1,l),(dgg(k,l),k = 1,nc,mc)
   26 continue
   27 format(1x,f7.4,30(1x,f9.5))
c
c     distribucion segun cuerda    
c              
      do 36 i = 1,nc
      write(32,37) oo(i,1), (gg(i,j),j = 1,nb,mb)
   36 continue
   37 format(1x,f7.4,30(1x,f9.5))
c            
      do 46 i = 1,nc
      write(64,47) oo(i,1),(dgg(i,j),j = 1,nb,mb)
   46 continue
   47 format(1x,f7.4,30(1x,f9.5))
c              
!      close(16)
      close(31)
      close(32)
      close(63)
      close(64)
c      
      return
      end        
c              
c--------------------------------------------------------------------------- fin
c 
c    11.            U      [m/s]    f12.5  (placa plana torsionada)
c    20.            omega  [1/s]    f12.5  
c     0.30          redvel [-]      f12.5  UU = U(1-a)             
c     0.70          coefa  [-]      f12.5  si index1 = 0, a = coefa*UU/w
c     0.30          ch     [m]      f12.5  c constante
c     0.30          ct     [m]      f12.5  c constante       
c     0.25          rh     [m]      f12.5
c     2.05          rt     [m]      f12.5
c     0.            oi     [rad]    f12.5  = 0.0
c     0.            of     [rad]    f12.5  valido para helicoide (index2 = 0)
c     0.030         pf     [m]      f12.5
c     1.001         beta   [-]      f12.5  Transformacion geometrica 1 
c     1.            signo  [-]      f12.5  +1. para extrados, -1. para intrados
c2000               nk              i4     numero PAR divisiones estela (max=2000)
c  1                nb     = 1      i3     numero de palas
c 30                nr     < 31     i3   
c 30                no     < 31     i3
c  4                np     < 5      i3     NP = 4 CB  (np = 0, solo pala)
c  1                npaso           i3 
c  1                index0          i3     si = 0, SOLO calculo total de la pala  
c +1                index1          i3     si (>0 a=UU/w, <0 a=U/w)
c +1                index2          i3     si = 0, helicoide; < 0, arco circular  
c  0                index3          i3     si = 0, inic = 2 (pala = 1)   
c  0                index4          i3     si = 0, no calcula @ c/4   
c  1                index5          i3     si = 0, solo geometria pala y estela  
c  0                index6          i3     si = 0, Dr = cte  
c  0                index7          i3     si = 0, Dc = cte; < 0 beta; > 0 cos/2 
c  0                index8          i3     si = 0, Dh = cte para CB anterior  
c  1                index9          i3     si = 0, ang.entre UU/Wr y coefa.UU/Wr
c  0                index10         i3     si = 0, Dc = cte para CB superior
c  0                index11         i3     P1 si =1, c/4 si =0, P2 si =2, etc 
c  0                index12         i3      
c     0.            alfac  [o]      f12.5  ang.ataque local, medido desde cuerda LINEAL
c     0.            alfac0 [o]      f12.5  ang.ataque local, medido desde cuerda CTE
c    20.            factor1[-]      f12.5  zult1 = factor1*rt (R tubo de corr.)
c    40.            factor2[-]      f12.5  zult2 = factor2*rt (lim.superior int.)
c     3.            zlim   [m]      f12.5  maxima longitud hilo estela p/grafic
c     0.0005        C1              f12.5  g(x,z) = C1 + C2~*SQRT(x)/f(z)
c     5.000         Cte2            f12.5  C2~ = cte2*(nu/Uo)^0.5
c     0.000         hc              f12.5  H/c del arco circular (p/index2 < 0)
c     
c------.-----
c123456789012       ENTVIS.IN
c
c-------------------------------------------------------------------------------
