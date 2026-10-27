import Caminos.*

//NUEVO: las opciones de cada camino.
//Mientras mas dificil el camino, mas estres suma cada opcion (extraEstres).
//Los numeros son de ejemplo: ajustalos para balancear el juego.
object cargaDeOpciones {

  method cargar() {
    caminoFacil.agregarOpciones(self.opciones(0))
    caminoMedio.agregarOpciones(self.opciones(5))
    caminoDificil.agregarOpciones(self.opciones(10))
  }

  method opciones(extraEstres) = [
    new Opcion(descripcion = "Estudiar toda la noche", resultado = "Sacaste 9, pero con ojeras", puntosAcademicos = 25, puntosEstres = 20 + extraEstres),
    new Opcion(descripcion = "Ir a la clase de consulta", resultado = "El profe te explicó todo", puntosAcademicos = 15, puntosEstres = 5 + extraEstres),
    new Opcion(descripcion = "Dormir una siesta", resultado = "Te despertaste de noche", puntosAcademicos = 0, puntosEstres = -15 + extraEstres),
    new Opcion(descripcion = "Estudiar con amigos", resultado = "Terminaron en la pizzería", puntosAcademicos = 10, puntosEstres = -5 + extraEstres),
    new Opcion(descripcion = "Hacer el TP en grupo", resultado = "Uno nunca contestó el grupo", puntosAcademicos = 20, puntosEstres = 10 + extraEstres),
    new Opcion(descripcion = "Ver un tutorial en YouTube", resultado = "Hasta que tuviste que aplicarlo", puntosAcademicos = 10, puntosEstres = 0 + extraEstres),
    new Opcion(descripcion = "Salir a caminar", resultado = "Te despejaste un montón", puntosAcademicos = 0, puntosEstres = -20 + extraEstres),
    new Opcion(descripcion = "Entregar el TP a último momento", resultado = "Llegaste con 1 minuto de sobra", puntosAcademicos = 20, puntosEstres = 25 + extraEstres),
    new Opcion(descripcion = "Pedir los apuntes a un compañero", resultado = "Dibujitos, pero algo sirvió", puntosAcademicos = 10, puntosEstres = 5 + extraEstres),
    new Opcion(descripcion = "Leer toda la teoría", resultado = "Entendiste la mitad", puntosAcademicos = 15, puntosEstres = 10 + extraEstres),
    new Opcion(descripcion = "Dormir 8 horas", resultado = "Energía, pero sin tiempo", puntosAcademicos = 5, puntosEstres = -20 + extraEstres),
    new Opcion(descripcion = "Ir al parcial sin estudiar", resultado = "Zafaste de milagro", puntosAcademicos = 10, puntosEstres = 25 + extraEstres)
  ]
}
