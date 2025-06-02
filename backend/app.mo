import HashMap "mo:base/HashMap";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import Debug "mo:base/Debug";
import Nat32 "mo:base/Nat32";
import Principal "mo:base/Principal";

actor Crud {

  type TutorID = Nat32;
  type ActividadID = Nat32;

  type Actividad = {
  titulo : Text;
  descripcion : Text;
  registroAlumno : Text;
  };

  type Tutor = {
    nombre : Text;
    correo : Text;
    contrasena : Text;
    InternetId : Principal
  };
  
  stable var actividadId : ActividadID = 0;
  var Actividades = HashMap.HashMap<Text, Actividad>(0, Text.equal, Text.hash);

  stable var tutorId : TutorID = 0;

  var tutores = HashMap.HashMap<Text, Tutor>(0, Text.equal, Text.hash);

  private func crear_Id() : Nat32 {
    tutorId += 1;
    return tutorId;

  };

  //actividades
  private func crearActividadId() : Text {
    actividadId += 1;
    return Nat32.toText(actividadId);
  };

  public shared func Crear_Actividad(titulo : Text, descripcion : Text, registroAlumno : Text) : async () {
    let actividad : Actividad = {titulo; descripcion; registroAlumno};
    let id = crearActividadId();
    Actividades.put(id, actividad);
  };

  public query func Listar_Actividades() : async [(Text, Actividad)] {
    Iter.toArray(Actividades.entries());
  };

  public shared func Actualizar_Actividad(id : Text, titulo : Text, descripcion : Text, registroAlumno : Text) {
    switch (Actividades.get(id)) {
      case (null) {};
      case (?_) {
        Actividades.put(id, {titulo; descripcion; registroAlumno});
      };
    };
  };

  public func Borrar_Actividad(id : Text) : async ?Actividad {
    Actividades.remove(id);
  };

  //login
  public query func Login_Tutor(correo : Text, contrasena : Text) : async Bool {
    let iter = tutores.entries();
    for ((id, tutor) in iter) {
      if (tutor.correo == correo and tutor.contrasena == contrasena) {
        return true;
      };
    };
    return false;
  };

  public shared (msg) func Crear_Tutor(nombre : Text, correo : Text, contrasena : Text) : async () {

    let internetId : Principal = msg.caller;
    let tutor : Tutor = {nombre; correo; contrasena; InternetId = internetId};
    tutores.put(Nat32.toText(crear_Id()), tutor);
    Debug.print("Se creo un nuevo tutor! ID: " # Nat32.toText(tutorId));

  };

  // This query method returns the currently persisted greeting with the given name.
  public query func Buscar_Tutor(id : Text) : async ?Tutor {
    let tutor : ?Tutor = tutores.get(id);
    return tutor;

  };

  public shared (msg) func Actualizar_Tutor(id : Text, nombre : Text, correo : Text, contrasena : Text) {
    let tutor : ?Tutor = tutores.get(id);
    switch (tutor) {
      case (null) {
        Debug.print("Tutor no encontrado")
      };
      case (?tutor) {
        let internetId : Principal = msg.caller;
        let TutorNuevo : Tutor = {
          nombre;
          correo;
          contrasena;
          InternetId = internetId
        };
        tutores.put(id, TutorNuevo)
      }

    }
  };

  public func borrar_tutor(id : Text) : async ?Tutor {
    tutores.remove(id)
  };

  type AsigID = Nat32;

  type Asig = {
    nombre : Text;
    calificacion : Nat;
    parcial : Nat;
    reg_Alumn : Text;
    materia : Text
  };

  stable var AsigId : AsigID = 0;

  var Asignaciones = HashMap.HashMap<Text, Asig>(0, Text.equal, Text.hash);

  private func crear_AsigId() : Nat32 {
    AsigId += 1;
    return AsigId;

  };

  public shared func Crear_Asig(nombre : Text, calificacion : Nat, parcial : Nat, reg_Alumn : Text, materia : Text) : async () {

    let asig : Asig = {nombre; calificacion; parcial; reg_Alumn; materia};
    Asignaciones.put(Nat32.toText(crear_AsigId()), asig);
    Debug.print("Se creo una nueva asignacion: " # Nat32.toText(AsigId));

  };

  // This query method returns the currently persisted greeting with the given name.
  public query func Buscar_Asig(id : Text) : async ?Asig {
    let asig : ?Asig = Asignaciones.get(id);
    return asig;

  };

  public query func Listar_Asig(hola : Text) : async [(Text, Asig)] {
    let AsigIter : Iter.Iter<(Text, Asig)> = Asignaciones.entries();
    let AsigArray : [(Text, Asig)] = Iter.toArray(AsigIter);
    return AsigArray;

  };

  public shared func Actualizar_Asig(id : Text, nombre : Text, calificacion : Nat, parcial : Nat, reg_Alumn : Text, materia : Text) {
    let asig : ?Asig = Asignaciones.get(id);
    switch (asig) {
      case (null) {
        Debug.print("Asignacion no encontrada")
      };
      case (?asig) {
        let AsigNueva : Asig = {
          nombre;
          calificacion;
          parcial;
          reg_Alumn;
          materia
        };
        Asignaciones.put(id, AsigNueva)
      }

    }
  };

  public func borrar_Asig(id : Text) : async ?Asig {
    Asignaciones.remove(id)
  };

  type AlumnID = Nat32;

  type Alumno = {
    nombre : Text;
    registro : Text
  };

  stable var alumnId : AlumnID = 0;

  var Alumnos = HashMap.HashMap<Text, Alumno>(0, Text.equal, Text.hash);

  private func crear_AlumnId() : Nat32 {
    alumnId += 1;
    return alumnId;

  };

  public shared func Crear_Alumn(nombre : Text, registro : Text) : async () {

    let alumn : Alumno = {nombre; registro};
    Alumnos.put(Nat32.toText(crear_AlumnId()), alumn);
    Debug.print("Se agrego un nuevo alumno: " # Nat32.toText(alumnId));

  };

  
  public query func Buscar_Alumn_por_Registro(registro : Text) : async ?Alumno {
    let iter = Alumnos.entries();
    for ((_, alumno) in iter) {
      if (alumno.registro == registro) {
        return ?alumno;
      };
    };
    return null;
  };

func getIdPorRegistro(registroBuscado : Text) : ?Text {
  var result : ?Text = null;

  for ((k, v) in Alumnos.entries()) {
    if (v.registro == registroBuscado) {
      result := ?k;
      
      
    }
  };

  return result;
  
};



  public query func Listar_Alumn(hola : Text) : async [(Text, Alumno)] {
    let AlumnIter : Iter.Iter<(Text, Alumno)> = Alumnos.entries();
    let AlumnArray : [(Text, Alumno)] = Iter.toArray(AlumnIter);
    return AlumnArray;

  };

  public shared func Actualizar_Alumn(id : Text, nombre : Text, registro : Text) {

     let idPorRegistro : ?Text = getIdPorRegistro(id);

    switch (idPorRegistro) {
    case null {
      Debug.print("No se encontró ningún alumno con ese registro.");
    };
    case (?idPorRegistro) {
      // Ahora usamos el id encontrado para actualizar
      let alumn : ?Alumno = Alumnos.get(idPorRegistro);
      switch (alumn) {
        case null {
          Debug.print("Alumno no encontrado después de encontrar el ID por registro.");
        };
        case (?a) {
          let NuevoAlumn : Alumno = { nombre; registro };
          Alumnos.put(idPorRegistro, NuevoAlumn);
          Debug.print("Alumno actualizado correctamente.");
        }
      }
    }
  }
};
  

  public func borrar_Alumn(registroBuscado : Text) : async ?Alumno {
    let idPorRegistro = getIdPorRegistro(registroBuscado);

    switch idPorRegistro {
      case null {
        null; // No se encontró ningún alumno con ese registro
      };
      case (?idEncontrado) {
        Alumnos.remove(idEncontrado); // Elimina y devuelve el valor borrado
      }
    }
  };

}
