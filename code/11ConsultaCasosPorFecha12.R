


library(R6)

library(DBI)
library(dbplyr)
library(dplyr)
library(odbc)


library(RPostgreSQL)

library(dplyr)
library(tidyverse)
library(hms)

library(writexl)



ConsultaScore <- R6Class(
  classname = "ConsultaScore"
  , public = list(
    
    DataSQL = NULL
    , Data11 = NULL
    , Data12 = NULL
    , DataFinal11 = NULL
    , FechaInicial = NULL
    , FechaFinal = NULL
    , Empresa = NULL
    , RangoFecha = NULL
    
    ,initialize = function(FechaInicial = NA, FechaFinal = NA, Empresa = NA){
      
      self$Data11 = NA
      self$Data12 = NA
      self$FechaInicial = FechaInicial
      self$FechaFinal = FechaFinal
      self$Empresa = Empresa
      
      self$DataSQL = NA
      self$DataFinal11 = NA
      
      self$RangoFecha = NA
      
      self$LimitesFechas()
      
    }
    
    ,LimitesFechas = function(){
      
      self$RangoFecha <- unique(c(self$FechaInicial, self$FechaFinal))
      
    }
    
    , InicioSesion = function(){
      
      self$DataSQL <- dbConnect(
        odbc(),
        Driver = "ODBC Driver 17 for SQL Server",
        # Driver = "SQL Server",
        # Driver = "FreeTDS",
        # TDS_Version = 7.4,
        Server = "eis-app.database.windows.net",
        Database = "eis",
        uid = "eis-pbi",
        pwd = "123ppp+++",
        #Trusted_Connection = TRUE,
        Port= 1433
      )
      
    }
    
    , ConsultaCasos = function(){
     
      if (length(self$RangoFecha) == 1) {
        
        query11 <- paste0(
        "
        select FechaPedido, adjusted_created_at, Empresa, emp, worker_name, OTD, OTDind, SumaScore, TiempoTotalPedidoMin, TiempoTotalCocinaMin
        from BD11_HistScoreDelivery
        where FechaPedido = ", "'", self$FechaInicial, "'", "
        and label = 'Entregado'
        and Empresa = ", "'", self$Empresa, "'", "
        ")
        
      } else {
        
        query11 <- paste0(
          "
        select FechaPedido, adjusted_created_at, Empresa, emp, worker_name, OTD, OTDind, SumaScore, TiempoTotalPedidoMin, TiempoTotalCocinaMin
        from BD11_HistScoreDelivery
        where FechaPedido >= ", "'", self$FechaInicial, "'", " and FechaPedido <= ", "'", self$FechaFinal, "'", "
        and label = 'Entregado'
        and Empresa = ", "'", self$Empresa, "'", "
        ")
        
      }
       
      self$Data11 <- dbGetQuery(self$DataSQL, sql(query11))
      
    }
    
    , Agrupaciones = function(){
      
      
      self$Data12 <- self$Data11 %>% 
        group_by(FechaPedido, emp) %>% 
        summarise(
          TotalCasos = n()
          , PromOTD = ifelse(is.na(mean(OTD, na.rm = TRUE)), 0, mean(OTD, na.rm = TRUE))
          , PromScoreDelivery = ifelse(is.na(mean(SumaScore, na.rm = TRUE)), 0, mean(SumaScore, na.rm = TRUE))
          , PromTiempoPedido = ifelse(is.na(mean(TiempoTotalPedidoMin, na.rm = TRUE)), 0, mean(TiempoTotalPedidoMin, na.rm = TRUE))
          , PromTiempoCocina = ifelse(is.na(mean(TiempoTotalCocinaMin, na.rm = TRUE)), 0, mean(TiempoTotalCocinaMin, na.rm = TRUE))
          , TotalDrivers = n_distinct(worker_name)
        ) %>% 
        ungroup() %>% 
        left_join(
          
          self$Data11 %>% 
            group_by(FechaPedido, emp) %>%
            summarise(
              Completados = sum(!is.na(adjusted_created_at))
              , EnProceso = sum(is.na(adjusted_created_at))
            )
          
          , by = c("FechaPedido" = "FechaPedido"
                   , "emp" = "emp"
          )
        ) %>% 
        left_join(
          
          self$Data11 %>%
            group_by(FechaPedido, emp, worker_name) %>% 
            summarise(PromedioScore = mean(SumaScore, na.rm = TRUE)) %>% 
            ungroup() %>% 
            mutate(
              Clasificacion = case_when(
                PromedioScore >= 0 & PromedioScore <= 40 ~ "Menor40",
                PromedioScore > 40 & PromedioScore <= 60 ~ "Entre40a60",
                PromedioScore > 60 & PromedioScore <= 80 ~ "Entre60a80",
                TRUE ~ "Mayor80"
              )
            ) %>% 
            mutate(Clasificacion = factor(Clasificacion, levels = c("Menor40", "Entre40a60", "Entre60a80", "Mayor80"))) %>% 
            group_by(FechaPedido, emp, Clasificacion, .drop  = FALSE) %>%
            summarise(
              TotalCasos = n()
            ) %>% 
            ungroup() %>% 
            pivot_wider(
              names_from = Clasificacion,
              values_from = TotalCasos
            )
          
          , by = c("FechaPedido" = "FechaPedido"
                   , "emp" = "emp"
          )
          
        ) %>%
        left_join(
          
          self$Data11 %>%
            group_by(FechaPedido, emp, OTDind, .drop = FALSE) %>% 
            summarise(
              TotalOTD = n() 
            ) %>% 
            mutate(TotalOTDpor1 = round(TotalOTD/sum(TotalOTD)*100, 2)) %>% 
            ungroup() %>% 
            filter(OTDind == 100) %>% 
            group_by(FechaPedido, emp, OTDind, .drop = FALSE) %>%
            summarise(
              TotalOTD = sum(TotalOTD),
              TotalOTDpor = sum(TotalOTDpor1)
            ) %>% 
            select(FechaPedido, emp, TotalOTD, TotalOTDpor)
          
          , by = c("FechaPedido" = "FechaPedido"
                   , "emp" = "emp")
        ) %>% 
        select(
          FechaPedido, emp, TotalCasos, Completados, EnProceso, TotalOTD, TotalOTDpor, PromScoreDelivery, PromTiempoCocina, PromTiempoPedido
          , TotalDrivers, Mayor80, Entre60a80, Entre40a60, Menor40
        ) 
      
      
      
    }
    
    , Evaluacion = function(){
      
      self$InicioSesion()
      self$ConsultaCasos()
      self$Agrupaciones()
      
    }
    
    , VisualizarInformacion = function(){
      
      return(
        self$Data12
      )
      
    }
    
    , ExportarInformacion = function(){
      
      write_xlsx(self$Data12, paste0("C:/Users/Administrador/Downloads/ScoreDelivery", self$Empresa, "_", self$FechaInicial, "_", self$FechaFinal, " ", format(Sys.time(),'%Y-%m-%d %H.%M.%S'), ".xlsx"))
      
    }
    
    
  )
)


Prueba11 = ConsultaScore$new(FechaInicial = "2024-02-01", FechaFinal = "2024-02-19", Empresa = "Primos")
Prueba11$Evaluacion()

DataPru11 <- Prueba11$VisualizarInformacion()
# View(DataPru11)

Prueba11$ExportarInformacion()


