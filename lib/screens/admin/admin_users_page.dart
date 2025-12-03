import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_user_provider.dart';
import '../../core/constants.dart';

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<AdminUserProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: prov.loading ? const Center(child: CircularProgressIndicator(color: PRIMARY_GREEN)) :
      ListView.builder(
        itemCount: prov.users.length,
        itemBuilder: (_, i) {
          final u = prov.users[i];
          return Card(
            color: Colors.grey.shade900,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: u.photoUrl != null && u.photoUrl!.isNotEmpty ? CircleAvatar(backgroundImage: NetworkImage(u.photoUrl!)) : CircleAvatar(child: Text(u.firstName.isEmpty ? 'U' : u.firstName[0])),
              title: Text('${u.firstName} ${u.lastName}', style: const TextStyle(color: Colors.white)),
              subtitle: Text(u.isAdmin ? 'Admin' : 'User', style: const TextStyle(color: Colors.white54)),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: u.disabled ? PRIMARY_GREEN : Colors.redAccent),
                  child: Text(u.disabled ? 'Activer' : 'Désactiver', style: const TextStyle(color: Colors.black)),
                  onPressed: () => prov.toggleDisable(u.uid, u.disabled),
                ),
                const SizedBox(width: 8),
                IconButton(icon: const Icon(Icons.refresh, color: Colors.white54), onPressed: () => prov.loadUsers()),
              ]),
            ),
          );
        },
      ),
    );
  }
}