import 'package:get/get.dart';
import 'package:pfe/core/widgets/app_main.dart';
import 'package:pfe/features/Auth/screens/login_page.dart';
import 'package:pfe/features/catalogue/catalogue_page.dart';
import 'package:pfe/features/clients/views/clients_page.dart';
import 'package:pfe/features/commande/views/screens/commercial_orders_page.dart';
import 'package:pfe/features/commande/views/screens/select_client_page.dart';
import 'package:pfe/features/commande/views/screens/select_products_page.dart';
import 'package:pfe/features/documents/documents_valides_page.dart';
import 'package:pfe/features/home/views/commercial_home_page.dart';
import 'package:pfe/features/objectif/views/objectifs_page.dart';
import 'package:pfe/features/profile/views/profile_page.dart';
import 'package:pfe/features/reclamation/reclamation_form_page.dart';
import 'package:pfe/features/reclamation/reclamation_home_page.dart';
import 'package:pfe/features/reclamation/reclamations_page.dart';
import 'package:pfe/features/visite/views/create_visite_page.dart';
import 'package:pfe/features/visite/views/map_circuit_page.dart';
import 'package:pfe/features/notifications/notifications_page.dart';


class AppRoutes {
  static const loginPage = '/login';
  static const homePage = '/home';
  static const commandesPage = '/commandes';
  static const selectProducts = '/select-products';
  static const selectClient = '/select-client';
  static const clientsPage = '/clients';
  static const visitesPage = '/visites';
  static const visiteForm = '/visite-form';
  static const mapCircuit = '/map-circuit';
  static const mesReclamations = '/reclamations/mes';
  static const newReclamation = '/reclamations/new';
  static const reclamationHome = '/reclamations/home';
  static const cataloguePage = '/catalogue';
  static const visiteCreate = '/visite/create';
  static const notificationsPage = '/notifications';
  static const documentsValidesPage = '/documents-valides';
  static const profilePage = '/profile';
  static const objectifsPage = '/objectifs';
  static const bottomNavWrapper= '/bottomNavWrapper';


}

class AppPages {
  static final routes = [
    GetPage(name: AppRoutes.loginPage, page: () => const LoginPage()),
    GetPage(name: AppRoutes.homePage, page: () => const CommercialHomePage()),
    GetPage(name: AppRoutes.commandesPage, page: () => CommercialOrdersPage()),
    GetPage(name: AppRoutes.selectProducts, page: () => const SelectProductsPage()),
    GetPage(name: AppRoutes.selectClient, page: () => SelectClientPage()),
    GetPage(name: AppRoutes.clientsPage, page: () => const ClientsPage()),
   
    GetPage(name: AppRoutes.mesReclamations, page: () => MesReclamationsPage()),
    GetPage(name: AppRoutes.newReclamation, page: () => ReclamationFormPage()),
    GetPage(name: AppRoutes.reclamationHome, page: () => const ReclamationHomePage()),
    GetPage(name: AppRoutes.cataloguePage, page: () => const CataloguePage()),
    GetPage(name: AppRoutes.visiteCreate, page: () => const CreateVisitePage()),
    GetPage(name: AppRoutes.mapCircuit, page: () => const MapCircuitPage()),
    GetPage(name: AppRoutes.notificationsPage, page: () => const NotificationsPage()),
    GetPage(name: AppRoutes.documentsValidesPage, page: () => const DocumentsValidesPage()),
    GetPage(name: AppRoutes.objectifsPage, page: () => ObjectifsPage()),
    GetPage(name: AppRoutes.bottomNavWrapper, page: () => BottomNavWrapper()),


    GetPage(
  name: AppRoutes.profilePage,
  page: () => ProfilePage(),
),

    
  ];
}
