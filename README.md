# r-tips

<br />

[This is the link text](## 5. Contabilizar los NAs por columnas)

<br />


## 1. Obtener resumen de un data frame

- Por medio de **glimpse()**

```r
glimpse(Data11)
```

<br />

- Utiliando **summarizeColumns()**

Se tiene que instalar primero la libreria ***library(mlr)***

```r
library(mlr)

summarizeColumns(Data11)
```

<br />
<br />

## 2. Llamar a una función de otro script

- Se crea un scripts con las funciones que se necesita **Funcion.R**

- Luego se llama al script a través de **source()**

- Por último, se llama a las funciones por su mismo nombre directamente

```r
source("C:/Users/.../funciones.R")

corre <- correlacionS(corre) # correlacionS: Nombre de la función en el archivo funciones.R 
```

<br />
<br />

## 3. Evaluar los NAs

<br />

```r
library(mice)

md.pattern(Data12, rotate.names = TRUE)
```


<br />
<br />


## 4. Aplicar una función a todo un conjunto de datos

<br />

- Para cambiar tipo de datos

```r
Data11 %>% 
  mutate(across(everything(), ~as.numeric(.)))
```



<br />
<br />


## 5. Contabilizar los NAs por columnas

<br />

```r
Data11 %>% 
  summarise_all(funs(sum(is.na(.))))
```


<br />
<br />






