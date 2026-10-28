import Caminos.*
import pantallas.*



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

  method aplicar(puntosAcademicos, puntosEstres) {
    self.modificarNivelAcademico(puntosAcademicos)
    self.modificarNivelEstres(puntosEstres)
  }

  method estresAlcanza(limite) = nivelEstres >= limite
  method academicoAlcanza(minimo) = nivelAcademico >= minimo

  method reiniciar(){
      nivelAcademico = 0
      nivelEstres = 0
  }
  method image() = "cerebros/Cerebro" + (nivelAcademico.div(10)) + ".gif" //Hay que aplicar en afectar

  method terminar() {
      self.reiniciar()
      modoDeJuego.resetear()
      menu.mostrar()
  }
  

}
