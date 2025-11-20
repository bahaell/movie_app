import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});

  Future<void> toggleDisabled(String uid, bool current) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'disabled': !current});
  }

  @override
  Widget build(BuildContext context) {
    final usersRef = FirebaseFirestore.instance.collection('users');
    return Container(
      padding: const EdgeInsets.all(12),
      child: StreamBuilder<QuerySnapshot>(
        stream: usersRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF53FC18)));
          final docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final d = docs[i].data() as Map<String, dynamic>;
              final docId = docs[i].id;
              final disabled = d['disabled'] ?? false;
              final isAdmin = d['isAdmin'] ?? false;
              return Card(
                color: Colors.grey.shade900,
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                child: ListTile(
                  leading: d['photoUrl'] != null && d['photoUrl'] != ''
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(d['photoUrl']))
                      : CircleAvatar(
                          child: Text(d['firstName']?.substring(0, 1) ?? 'U')),
                  title: Text('${d['firstName'] ?? ''} ${d['lastName'] ?? ''}',
                      style: const TextStyle(color: Colors.white)),
                  subtitle: Text(
                      '${isAdmin ? 'Admin' : 'User'} • Age: ${d['age'] ?? '-'}',
                      style: const TextStyle(color: Colors.white54)),
                  trailing: ElevatedButton(
                    onPressed: () => toggleDisabled(docId, disabled),
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            disabled ? Colors.green : Colors.redAccent,
                        foregroundColor: Colors.black),
                    child: Text(disabled ? 'Activer' : 'Désactiver'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
