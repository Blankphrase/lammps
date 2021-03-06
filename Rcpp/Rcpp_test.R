library(Rcpp)
cppFunction("
            int one(){
                return 1;
            }
            ")
library(microbenchmark)
one2=function(){1}

microbenchmark(one(),one2(),times=1000)

## R's built-in function is faster this time. 
##########################################################
sign_func=function(x){
  if(x>0){
    1
  }else if (x==0){
    0
  }else if (x<0){
    -1
  }
}

cppFunction("
            int sign_func2(int x){
          if (x>0){
            return 1;
          }else if (x==0){
            return 0;
          }else if (x<0){
            return -1;
          }
            }
            ")
microbenchmark(sign_func(1000),sign_func2(1000),times=10000)
microbenchmark(sign_func(0),sign_func2(0),times=10000)
microbenchmark(sign_func(-1000),sign_func2(-1000),times=10000)
# R's built-in function is much faster. 
################################################################
sum_func=function(x){
  total=0
  for (i in 1:length(x)){
    total=total+x[i]
  }
  return(total)
}

cppFunction('
double sum_func2(NumericVector x){
  int n=x.size();
  double total=0;
  for(int i=0;i<n;i++){
  total+=x[i];
  }
return(total);
}            
            
')

x=runif(1e7)
microbenchmark(sum(x),sum_func(x),sum_func2(x))
# R's built-in function sum is the fastest, Rcpp function is the a close second, while self-defined function is the slowest. 
################################################################

distance=function(x,y){
  sqrt((x-y)^2)
}

cppFunction("
            NumericVector distance2(NumericVector x, NumericVector y){
                  int n=y.size();
                  NumericVector out(n);
                  for(int i=0;i<n;++i){
                      out[i]=sqrt(pow(y[i]-x[i],2.0));
                  }
                  return out;
            }
            ")

y=runif(1e7)

microbenchmark(distance(x,y),distance2(x,y),times=1000)
# R's function is still a little bit faster
################################################################

cppFunction("
            NumericVector rowSums_C(NumericMatrix x){
                int nrow=x.nrow(),ncol=x.ncol();
                NumericVector out(nrow);

                for(int i=0;i<nrow;i++){
                  double total=0;
                  for(int j=0;j<ncol;j++){
                    total+=x(i,j);
                  }
                  out[i]=total;
                }
             return out; 
            } 
            
            
            ")
x=matrix(10*1e7,runif(10*1e7),ncol=10,nrow=1e7)
y=matrix(1e7*10,runif(10*1e7),ncol=1e7,nrow=10)

microbenchmark(rowSums(x),rowSums_C(x),times=500 ) 
# 10^7 of rows nad 10 columns
# The C code is faster in this situation.


microbenchmark(rowSums(y),rowSums_C(y),times=500 )
# there is 10 rows but 10^7 columns. 
# The C code is slower in this situation. 

################################################################
sourceCpp("meanC.cpp")
# This time the C code is slightly faster than the default mean function in R.

################################################################
sourceCpp("lapply_C.cpp")
 
# This time the default lapply is much faster than the C code I wrote. 
################################################################

sourceCpp("scalar_missing.cpp")
str(scalar_missing())
# The behavior of missing value in C is a little different than R. 
###########################################################

sourceCpp("cumsum_C.cpp")
x=rnorm(1e7)
library(microbenchmark)
microbenchmark(cumsum(x),cumsum_C(x),times=1000)
