import Consumibles.*
 class Camino{
    var paresDeCaminos=[]
    var opciones = []
   

  method izquierda() = opciones.first()
  method derecha() = opciones.last()

  method elegirIzquierda() {
    self.izquierda().seleccionado()
  }

  method elegirDerecha() {
    self.derecha().seleccionado()
  }
}
 

class CaminoAleatorio inherits Camino{
    method sortear() {
    const primero = paresDeCaminos.anyOne()
    const segundo = paresDeCaminos.filter({ c => c != primero }).anyOne()
    opciones = [primero, segundo]
  }

}

const caminoFacil = new Camino ()

const caminoMedio = new Camino ()

const caminoDificil = new Camino()

const caminoAleatorio = new CaminoAleatorio()



object caminoElegido {
    var caminoActual = caminoFacil
    method cambiarA(unCamino){ caminoActual = unCamino}

}