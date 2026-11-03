import wollok.game.*
import pantallas.*

object barraAcademica {
  const property position = game.at(27, 14.2)
  var nivelAcademico = 0
  var nivelEstres = 0

  // para que no se pase de 100 ni sea negativo
  method limitar(valor) = valor.max(0).min(100)

  method modificarNivelAcademico(puntos) { nivelAcademico = self.limitar(nivelAcademico + puntos) }
  method modificarNivelEstres(puntos) { nivelEstres = self.limitar(nivelEstres + puntos) }

  method aplicar(puntosAcademicos, puntosEstres) {
    self.modificarNivelAcademico(puntosAcademicos)
    self.modificarNivelEstres(puntosEstres)
    alertaEstres.actualizar() // si el estres esta alto, avisa
  }

  method borrarEstres() {
    nivelEstres = 0
    alertaEstres.actualizar()
  }

  method asegurarNivel(minimo) { nivelAcademico = nivelAcademico.max(minimo) }

  method estresAlcanza(limite) = nivelEstres >= limite
  method sinConocimiento() = nivelAcademico == 0

  method reiniciar() {
    nivelAcademico = 0
    self.borrarEstres()
  }

  method image() = "cerebros/Cerebro" + nivelAcademico.div(2) + ".png" // 51 cerebros: uno cada 2 puntos (0 a 100)
}

object alertaEstres {
  const property position = game.at(26, 5.5)
  const nivelPeligro = 60
  const nivelCritico = 80

  method image() =
    if (barraAcademica.estresAlcanza(nivelCritico)) "alerta_critica.gif"
    else "alerta_peligro.gif"

  method debeMostrarse() = barraAcademica.estresAlcanza(nivelPeligro)

  method actualizar() {
    if (self.debeMostrarse()) visuales.mostrar([self]) else visuales.ocultar([self])
  }
}
