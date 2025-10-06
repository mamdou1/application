import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../StockageDeToken.dart';
import '../entite/evenement_model.dart';
import 'evenement_service.dart';
import 'details_evenement_dialog.dart';

class CalendrierDetails extends StatefulWidget {
  const CalendrierDetails({super.key});

  @override
  State<CalendrierDetails> createState() => _CalendrierDetailsState();
}

class _CalendrierDetailsState extends State<CalendrierDetails> {
  List<EvenementModel> _evenements = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchEvenements();
  }

  Future<void> _fetchEvenements() async {
    final stockageToken = Provider.of<StockageDeToken>(context, listen: false);
    final String? token = stockageToken.token;

    if (token == null || token.isEmpty) {
      setState(() {
        _errorMessage = 'Token manquant. Veuillez vous reconnecter';
        _isLoading = false;
      });
      return;
    }

    try {
      final evenements = await EvenementService.fetchEvenements(token);
      setState(() {
        _evenements = evenements;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // 🔥 CONVERTIR LES ÉVÉNEMENTS EN APPOINTMENTS POUR LE CALENDRIER
  List<Appointment> _getAppointments() {
    return _evenements.map((evenement) {
      Color appointmentColor;

      // Définir la couleur selon le statut
      switch (evenement.statutEvent) {
        case 'EN_COURS':
          appointmentColor = Colors.green;
          break;
        case 'EN_ATTENTE':
          appointmentColor = Colors.orange;
          break;
        case 'TERMINER':
          appointmentColor = Colors.grey;
          break;
        default:
          appointmentColor = Colors.blue;
      }

      return Appointment(
        startTime: evenement.dateDebut,
        endTime: evenement.dateFin,
        subject: evenement.nom,
        color: appointmentColor,
        notes: evenement.description,
        // Stocker l'ID de l'événement pour récupérer les détails
        id: evenement.id,
      );
    }).toList();
  }

  // 🔥 GESTION DU CLIC SUR UN ÉVÉNEMENT
  void _onCalendarTap(CalendarTapDetails details) {
    if (details.targetElement == CalendarElement.appointment ||
        details.targetElement == CalendarElement.agenda) {
      final Appointment appointment = details.appointments![0];
      final int eventId = appointment.id as int;

      _showEvenementDetails(eventId);
    }
  }

  // 🔥 AFFICHER LES DÉTAILS D'UN ÉVÉNEMENT
  void _showEvenementDetails(int eventId) async {
    final stockageToken = Provider.of<StockageDeToken>(context, listen: false);
    final String? token = stockageToken.token;

    if (token == null) return;

    try {
      final evenement = await EvenementService.fetchEvenementDetails(eventId, token);

      // Afficher la boîte de dialogue des détails
      DetailsEvenementDialog.show(
        context: context,
        evenement: evenement,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        //borderRadius: BorderRadius.circular(12),
      ),
      child: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.orange[900]))
          : _errorMessage != null
          ? Center(
        child: Text(
          _errorMessage!,
          style: TextStyle(color: Colors.red, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      )
          : SfCalendar(
        view: CalendarView.month,
        initialSelectedDate: DateTime.now(),
        dataSource: _getDataSource(),

        // 🔥 COULEUR DE LA SÉLECTION
        selectionDecoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.3),
          border: Border.all(
            color: Colors.orange,
            width: 2.0,
          ),
          shape: BoxShape.rectangle,
        ),

        // 🔥 COULEUR DE FOND DU JOUR ACTUEL
        todayHighlightColor: Colors.orange[900]!,

        // 🔥 STYLE DU TEXTE DES JOURS
        monthViewSettings: MonthViewSettings(
          monthCellStyle: MonthCellStyle(
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            trailingDatesTextStyle: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
            leadingDatesTextStyle: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          // Afficher le nom des événements dans les cellules
          showAgenda: true,
        ),

        // 🔥 GESTION DU CLIC SUR LES ÉVÉNEMENTS
        onTap: _onCalendarTap,

        // 🔥 STYLE DES APPOINTMENTS (ÉVÉNEMENTS)
        appointmentBuilder: (context, details) {
          return Container(
            decoration: BoxDecoration(
              color: details.appointments.first.color,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                details.appointments.first.subject,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        },
      ),
    );
  }

  // 🔥 SOURCE DE DONNÉES POUR LE CALENDRIER
  _DataSource _getDataSource() {
    return _DataSource(_getAppointments());
  }
}

// 🔥 CLASSE POUR LA SOURCE DE DONNÉES DU CALENDRIER
class _DataSource extends CalendarDataSource {
  _DataSource(List<Appointment> source) {
    appointments = source;
  }
}