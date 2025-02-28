// text_constants.dart
class TextConstants {
  // Auth Screens
  static const String loginTitle = 'Bienvenido a Povo';
  static const String loginSubtitle = 'Captura los mejores momentos juntos';
  static const String signupTitle = 'Crear cuenta';
  static const String signupSubtitle = 'Únete y captura momentos increíbles';

  // Form Labels
  static const String email = 'Correo electrónico';
  static const String password = 'Contraseña';
  static const String confirmPassword = 'Confirmar contraseña';
  static const String name = 'Nombre';
  static const String forgotPassword = '¿Olvidaste tu contraseña?';

  // Button Labels
  static const String login = 'Iniciar sesión';
  static const String signup = 'Crear cuenta';
  static const String continueWithGoogle = 'Continuar con Google';
  static const String dontHaveAccount = '¿No tienes una cuenta?';
  static const String alreadyHaveAccount = '¿Ya tienes una cuenta?';

  // Home Screen
  static const String myEvents = 'Mis Eventos';
  static const String participating = 'Participando';
  static const String noHostedEvents = 'No has creado ningún evento';
  static const String noParticipatingEvents =
      'No estás participando en ningún evento';
  static const String createEventCTA =
      'Crea un evento para comenzar a capturar fotos';
  static const String joinEventCTA =
      'Únete a un evento con un código de acceso';

  // Event Creation
  static const String createEvent = 'Crear Evento';
  static const String eventName = 'Nombre del evento*';
  static const String eventDescription = 'Descripción (opcional)';
  static const String eventLocation = 'Ubicación (opcional)';
  static const String startDate = 'Fecha inicio*';
  static const String endDate = 'Fecha fin (opcional)';
  static const String addCoverPhoto = 'Agregar foto de portada';

  // Moderation Settings
  static const String moderationSettings = 'Configuración de moderación';
  static const String moderationDescription =
      'Activa la moderación para aprobar las fotos antes de que sean visibles para todos los participantes.';
  static const String requirePhotoApproval = 'Requerir aprobación de fotos';
  static const String moderationEnabled = 'Moderación activada';
  static const String moderationDisabled = 'Moderación desactivada';
  static const String moderationEnabledDesc =
      'Las fotos deben ser aprobadas antes de aparecer en la galería.';
  static const String moderationDisabledDesc =
      'Las fotos aparecen inmediatamente en la galería.';

  // Join Event
  static const String joinEvent = 'Unirse a un evento';
  static const String scanQrCode = 'Escanea este código QR';
  static const String shareQrDescription =
      'Comparte este código QR para que otros usuarios puedan unirse a tu evento fácilmente';
  static const String orShareCode = 'O comparte este código';
  static const String enterAccessCode =
      'Ingresa el código de acceso proporcionado por el anfitrión del evento';

  // Camera Screen
  static const String takePhoto = 'Tomar foto';
  static const String usePhoto = 'Usar foto';
  static const String retakePhoto = 'Volver a tomar';
  static const String addCaption = 'Añadir una descripción... (opcional)';

  // Gallery Screen
  static const String noPhotosYet = 'Aún no hay fotos en este evento';
  static const String beFirstToCapture = 'Sé el primero en capturar un momento';

  // Moderation Screen
  static const String moderatePhotos = 'Moderación de fotos';
  static const String pendingTab = 'Pendientes';
  static const String approvedTab = 'Aprobadas';
  static const String rejectedTab = 'Rechazadas';
  static const String noPendingPhotos = 'No hay fotos pendientes de aprobación';
  static const String noApprovedPhotos = 'No has aprobado ninguna foto';
  static const String noRejectedPhotos = 'No has rechazado ninguna foto';
  static const String approveAll = 'Aprobar todas';

  // Action Buttons
  static const String approve = 'Aprobar';
  static const String reject = 'Rechazar';
  static const String delete = 'Eliminar';
  static const String share = 'Compartir';
  static const String download = 'Descargar';
  static const String edit = 'Editar';
  static const String cancel = 'Cancelar';
  static const String save = 'Guardar';
  static const String takePhotos = 'Tomar fotos';
  static const String viewGallery = 'Ver galería';

  // Confirmation Dialogs
  static const String deleteEventTitle = 'Eliminar evento';
  static const String deleteEventMessage =
      '¿Estás seguro de que quieres eliminar este evento? Esta acción no se puede deshacer y se eliminarán todas las fotos asociadas.';
  static const String leaveEventTitle = 'Salir del evento';
  static const String leaveEventMessage =
      '¿Estás seguro de que quieres salir de este evento? Ya no podrás ver las fotos ni añadir nuevas.';
  static const String deletePhotoTitle = 'Eliminar foto';
  static const String deletePhotoMessage =
      '¿Estás seguro de que quieres eliminar esta foto? Esta acción no se puede deshacer.';

  // Error Messages
  static const String errorLoadingData =
      'Error al cargar los datos. Intente nuevamente.';
  static const String errorCreatingEvent =
      'Error al crear el evento. Intente nuevamente.';
  static const String errorJoiningEvent =
      'Error al unirse al evento. Intente nuevamente.';
  static const String errorTakingPhoto =
      'No se pudo capturar la foto. Intente nuevamente.';
  static const String errorUploadingPhoto =
      'No se pudo subir la foto. Intente nuevamente.';
  static const String invalidCode =
      'Código de evento inválido o evento inactivo';
  static const String alreadyJoined = 'Ya eres participante de este evento';
}
