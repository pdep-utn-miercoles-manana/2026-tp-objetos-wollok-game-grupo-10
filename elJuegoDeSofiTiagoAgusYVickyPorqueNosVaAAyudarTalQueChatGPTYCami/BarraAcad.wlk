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
    alertaEstres.actualizar() // si el estres esta alto, avisa
  }

  method asegurarNivel(minimo) { nivelAcademico = nivelAcademico.max(minimo) }

  method estresAlcanza(limite) = nivelEstres >= limite
  method academicoAlcanza(minimo) = nivelAcademico >= minimo

  method reiniciar(){
      nivelAcademico = 0
      nivelEstres = 0
      alertaEstres.actualizar()
  }
  method image() = "cerebros/Cerebro" + (nivelAcademico.div(2)) + ".png" // 51 cerebros: uno cada 2 puntos (0 a 100)

  method terminar() {
      self.reiniciar()
      modoDeJuego.resetear()
      menu.mostrar()
  }
  

}

// Icono de peligro: aparece cuando el estres empieza a subir mucho y se pone rojo cuando esta por llegar al limite.
object alertaEstres {
  const property position = game.at(26, 5.5)
  const nivelPeligro = 60
  const nivelCritico = 80

  method image() =
    if (barraAcademica.estresAlcanza(nivelCritico)) "alerta_critica.gif"
    else "alerta_peligro.gif"

  method debeMostrarse() = barraAcademica.estresAlcanza(nivelPeligro)

  method actualizar() {
    if (self.debeMostrarse() and not game.hasVisual(self)) {
      game.addVisual(self)
    } else if (not self.debeMostrarse() and game.hasVisual(self)) {
      game.removeVisual(self)
    }
  }
}
