library(shiny)
library(RODBC)
library("rjson")


shinyServer(function(input, output, session) {
  myconn <- odbcConnect("XE", uid="Data Analytic", pwd="playmaker")
  sqlstr <- paste("select distinct year from datentime")
  y <- sqlQuery(myconn,sqlstr)
  close(myconn)
  
  output$dropdown1 <- renderUI(selectInput('year','Year',y[,1]))
  output$dropdown2 <- renderUI(
    if (is.null(input$year)){
      return()
    }else{
      mycon <- odbcConnect("XE",uid = "Data Analytic", pwd = "playmaker")
      sqlstr <- paste("select distinct ID, month from datentime where year=trim('",input$year,"') order by ID")
      m <- sqlQuery(mycon,sqlstr)
      mmat <- matrix(m$MONTH)
      close(mycon)
      selectInput('month','Month',mmat[,1])
    }
  )
  
  data_totalincome <- reactive(
    if ((is.null(input$year))|(is.null(input$month))){
      return()
    }else{
      cyear=input$year
      cmonth=input$month
      mycon <- odbcConnect("XE",uid = "Data Analytic", pwd = "playmaker")
      sqlstr <- paste("select distinct ID from datentime where month=trim('",cmonth,"') and year=trim('",cyear,"')")  
      id <- sqlQuery(mycon,sqlstr)
      sqlstr2 <- paste("select distinct totalincome from totalincome where ID=",id[,1])
      ti <- sqlQuery(mycon,sqlstr2)
      if (ti$TOTALINCOME <= 1000000){
        ti$t3 <- 1000000
      }else if(ti$TOTALINCOME > 1000000 & ti$TOTALINCOME <=10000000){
        ti$t3 <- 10000000
      }else{
        ti$t3 <- 100000000
      }
      ti$t1<- floor(ti$t3/3)
      ti$t2<- floor((ti$t3/3)*2)
      jti <- list(totalincome = ti$TOTALINCOME, t1 = ti$t1,t2=ti$t2,t3=ti$t3)
      close(mycon)
      return(jti)
    }
  )
  
  observe(session$sendCustomMessage(type = 'totalincome',message = data_totalincome()))
  
  data_stock <- reactive(
    if ((is.null(input$year))|(is.null(input$month))){
      return()
    }else{
      cyear=input$year
      cmonth=input$month
      mycon <- odbcConnect("XE",uid = "Data Analytic", pwd = "playmaker")
      sqlstr <- paste("select distinct ID from datentime where month=trim('",cmonth,"') and year=trim('",cyear,"')")  
      id <- sqlQuery(mycon,sqlstr)
      sqlstr2 <- paste("select distinct totalsolar,remsolar,totalpremium,rempremium,totalpertamax,rempertamax from stock where ID=",id[,1])
      s <- sqlQuery(mycon,sqlstr2)
      s$psolar <- ceiling((s$REMSOLAR/s$TOTALSOLAR)*100)
      s$ppremium <- ceiling((s$REMPREMIUM/s$TOTALPREMIUM)*100)
      s$ppertamax <- ceiling((s$REMPERTAMAX/s$TOTALPERTAMAX)*100)
      js <- list(psolar = s$psolar, ppremium = s$ppremium,ppertamax=s$ppertamax)
      close(mycon)
      return(js)
    }
  )
  
  observe(session$sendCustomMessage(type = 'stock',message = data_stock()))
  
  data_volumetype <- reactive(
    if ((is.null(input$year))|(is.null(input$month))){
      return()
    }else{
      cyear=input$year
      cmonth=input$month
      mycon <- odbcConnect("XE",uid = "Data Analytic", pwd = "playmaker")
      sqlstr <- paste("select a.ID,b.Solar1,b.Premium1,b.Pertamax1,b.Solar2,b.Premium2,b.Pertamax2,b.Solar3,b.Premium3,b.Pertamax3,b.Solar4,b.Premium4,b.Pertamax4,b.Solar5,b.Premium5,b.Pertamax5 from datentime a,volumetype b where a.year=trim('",cyear,"') and a.month=trim('",cmonth,"') and a.ID=b.ID order by a.ID;")
      vt <- sqlQuery(mycon,sqlstr)
      close(mycon)
      jvt <- list(solar1 = vt$SOLAR1,premium1=vt$PREMIUM1,pertamax1=vt$PERTAMAX1,solar2 = vt$SOLAR2,premium2=vt$PREMIUM2,pertamax2=vt$PERTAMAX2,solar3 = vt$SOLAR3,premium3=vt$PREMIUM3,pertamax3=vt$PERTAMAX3,solar4 = vt$SOLAR4,premium4=vt$PREMIUM4,pertamax4=vt$PERTAMAX4,solar5 = vt$SOLAR5,premium5=vt$PREMIUM5,pertamax5=vt$PERTAMAX5)
      return(jvt)
    }
  )
  
  observe(session$sendCustomMessage(type = 'volumetype',message = data_volumetype()))
  
  data_price <- reactive(
    if ((is.null(input$year))|(is.null(input$month))){
      return()
    }else{
      cyear=input$year
      cmonth=input$month
      mycon <- odbcConnect("XE",uid = "Data Analytic", pwd = "playmaker")
      sqlstr <- paste("select b.solar,b.premium,b.pertamax from datentime a,price b where a.ID=b.ID and a.year=trim('",cyear,"') and a.month=trim('",cmonth,"');")
      p <- sqlQuery(mycon,sqlstr)
      close(mycon)
      jp <- list(solar = p$SOLAR,premium = p$PREMIUM, pertamax = p$PERTAMAX)
      return(jp)
    }
  )
  
  observe(session$sendCustomMessage(type = 'price',message = data_price()))
})
