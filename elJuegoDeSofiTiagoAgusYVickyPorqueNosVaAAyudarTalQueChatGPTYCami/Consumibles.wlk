import BarraAcad.*
class Consumible{
  var property position=game.at(0, 0)
  const puntosAcademicos 
  const puntosEstres 
  const imagen
  method image() = imagen
  method seleccionado() {
     barraAcademica.subirAcademico(puntosAcademicos)
     barraAcademica.subirEstres(puntosEstres)
     game.removeVisual(self)
  }
 }

const chocolate = new Consumible( puntosAcademicos =10, puntosEstres=0, imagen ="Consumibles/Choco.gif")
const bestia = new Consumible(puntosAcademicos=15, puntosEstres=5, imagen="Consumibles/Energetica.gif") 