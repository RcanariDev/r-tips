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

## 7. Graficar todas las variables de un dataframe

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

## 8. Graficar las varibles de dataframe (Otra forma)

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







