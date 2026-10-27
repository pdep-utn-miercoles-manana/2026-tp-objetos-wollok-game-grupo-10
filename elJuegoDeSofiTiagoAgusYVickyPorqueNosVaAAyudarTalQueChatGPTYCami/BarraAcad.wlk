
 object barraAcademica{
  var property position = game.at(27, 14.2)
  var nivelAcademico = 0
  var nivelEstres = 0

  method nivelAcademico() = nivelAcademico
  method nivelEstres() = nivelEstres
//para que no se pase de 100 ni negativo
  method limitar(valor) = valor.max(0).min(100)

  method modificarNivelAcademico(puntos) { nivelAcademico = self.limitar(nivelAcademico + puntos) }
  method modificarNivelEstres(puntos) { nivelEstres = self.limitar(nivelEstres + puntos) }

  method reiniciar(){
      nivelAcademico = 0
      nivelEstres = 0
  }
  method image() = "cerebros/Cerebro" + (nivelAcademico.div(10)) + ".gif" //Hay que aplicar en afectar
}
