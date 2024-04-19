# r-tips

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


```r
DataAcademic11 %>% 
  mutate(across(everything(), ~as.numeric(as.character(.))))
```

<br />

- Otro ejemplo

```r
Train12 <- Train11 %>% 
  mutate(across(everything(), ~ifelse(.=="NA", NA, .)))
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

## 6. Crear una data de entrenamiento y de prueba

<br />

1. Poner una semilla
2. Crear una columna que identifique a cada registro
3. Crear la data de entrenamiento
4. Crear la data de prueba

<br />

```r
library(dplyr)

Data11 <- iris
dim(Data11) #150

# Estableciendo una semilla
set.seed(1)

# Se debe crear una columna Id
Data12 <- Data11 %>% 
  mutate(Id = 1:nrow(.), .before = Sepal.Length)

# Seleccionando el train (105)
train <- Data12 %>% 
  sample_frac(.7)

# Seleccionando el test (45)
test <- Data12 %>% 
  anti_join(train
            , by = "Id") 

```


<br />
<br />

## 7. Graficar todas las variables de un dataframe (1 forma)

<br />

Buscar más información en: [Link](https://github.com/bcgov/elucidate/)

<br />

1. Para instalar

```r
library(remotes)
remotes::install_github("bcgov/elucidate")
```

<br />
  
2. Aplicar

```r
library(elucidate)

plot_var_all(iris) 
```

<br />

3. Aplicado en función de otra variable

```r
plot_var_all(Data11, var2 = Species) 
```

<br />
<br />

## 8. Graficar las varibles de dataframe (2 forma)

<br />

Llamar a la libreria: **library(tidyr)**

<br />

- Solo para variables numéricas

```r
iris %>% 
  select_if(is.numeric) %>% 
  gather %>% 
  ggplot(aes(x = value)) + 
  geom_histogram() + 
  facet_wrap(~key)
```

- Solo para variables factor

```r
iris %>% 
  select_if(is.factor) %>% 
  gather %>% 
  ggplot(aes(x = value)) + geom_bar() +
  facet_wrap(~key) +
  coord_flip()
```




<br />
<br />

## 9. Graficar las varibles de dataframe (3 forma)

<br />

Llamar a la libreria: **library(GGallyr)**

<br />

```r
library(GGally)

ggpairs(iris)
```


<br />
<br />

## 10. Seleccionar variables tipos numéricas y factores

<br />

- Variables de tipo numéricas

```r
Train14Num <- Train14 %>% 
  select_if(is.numeric) 
```

<br />

- Excluir las numéricas

<br />

```r
library(tidyverse)
Data11 %>% 
  select_if(negate(is.numeric))
```

<br />

- Variables de tipo character

```r
Train14NoNum <- Train14 %>% 
  select_if(is.character)
```



<br />
<br />


## 11. Extraer los primeros n caracteres de una cadena de texto

<br />

Se utiliza la libreria **stringr**

<br />

Extrayendo los primeros *n* caracteres

```r
library(stringr)

Data11 %>% 
  mutate(Anio = str_sub(FechaMesOrdenAjustado, 1, n))

```


<br />
<br />


## 12. Restar fechas seguidas para cada categoria

<br />

- Inicialmente se tiene agrupado por las categorias
 
```r
DataCanal11 %>% 
  filter(FechaAjustada %in% c("2023-04-05", "2024-03-27")) %>% 
  filter(NombreCompania == "DON TITO")
```

<br />

<img src="/img/Contras12.jpg" width=60% height=60%>

<br />

<br />

- Luego se resta las categorias que son seguidas por fecha, con la función **lag()**


```r
DataCanal11 %>% 
  filter(FechaAjustada %in% c("2023-04-05", "2024-03-27")) %>% 
  filter(NombreCompania == "DON TITO") %>% 
  group_by(CanalVenta) %>% 
  mutate(
    DifTotal = (TotalCasos - lag(TotalCasos))/lag(TotalCasos)*100
  )

```

<br />


<img src="/img/Contras11.jpg" width=60% height=60%>

<br />


<br />
<br />



## 13. Uso de grepl() para patrones

<br />

- Si contiene: **grepl("-01", FechaMesOrdenAjustado)**
- No contiene: **!grepl("-01", FechaMesOrdenAjustado)**
- Contiene varios valores (ó) (|): **grepl("-01|-02", FechaMesOrdenAjustado)**

<br />

```r
Data11 %>% 
  mutate(Mes = case_when(
    grepl("-01", FechaMesOrdenAjustado) ~ "Enero",
    grepl("-02", FechaMesOrdenAjustado) ~ "Febrero",
    grepl("-03", FechaMesOrdenAjustado) ~ "Marzo",
    grepl("-04", FechaMesOrdenAjustado) ~ "Abril"
  ), .before = FechaMesOrdenAjustado)

```

<br />
<br />


# 14. Mostrar resumen de SOLO las variables numéricas

<br />

- Se utiliza la función **profiling_num()**

<br />

```r
library(funModeling)

profiling_num(Data11)

```

<br />
<br />

