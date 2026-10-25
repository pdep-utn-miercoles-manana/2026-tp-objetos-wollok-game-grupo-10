
 object barraAcademica{
  var property position = game.at(27, 15)
  var nivelAcademico = 30
  var nivelEstres = 0

  method nivelAcademico() = nivelAcademico
  method nivelEstres() = nivelEstres
//para que no se pase de 100 ni negativo
  method limitar(valor) = valor.max(0).min(100)

  method subirAcademico(puntos) { nivelAcademico = self.limitar(nivelAcademico + puntos) }
  method bajarAcademico(puntos) { nivelAcademico = self.limitar(nivelAcademico - puntos) }

  method subirEstres(puntos) { nivelEstres = self.limitar(nivelEstres + puntos) }
  method bajarEstres(puntos) { nivelEstres = self.limitar(nivelEstres - puntos) }

  method image() = "cerebros/Cerebro" + (nivelAcademico.div(10)) + ".gif"
}
