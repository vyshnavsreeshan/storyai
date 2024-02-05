import 'package:flutter/material.dart';

class UserAgreementScreen extends StatelessWidget {
  const UserAgreementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Row(
            children: [
              Text(
                'User Agreement',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'USER AGREEMENT',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    'Welcome to BookBuddies! By using our application, you agree to be bound by the terms and conditions outlined below.',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    '1. DESCRIPTION OF SERVICE',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    'BookBuddies is an online platform that allows users to rent, buy, and sell books. The service provided by the application includes the following features:',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 8.0),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const <Widget>[
                        Text('- User registration and login'),
                        Text(
                            '- Search for books by title, author, or location'),
                        Text('- Add books to a wishlist'),
                        Text('- Rent or buy books from other users'),
                        Text('- Post reviews and comments on books'),
                        Text('- Follow other users and see their activity'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    '2. ACCEPTANCE OF TERMS',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    'By using BookBuddies, you agree to comply with and be bound by the following terms and conditions of use. If you do not agree to these terms, please do not use the application.',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    '3. REGISTRATION AND ACCOUNT SECURITY',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    'In order to use the BookBuddies application, users must create an account by providing accurate and current information. Users are responsible for maintaining the security of their account and password, and for all activities that occur under their account. BookBuddies reserves the right to terminate user accounts, refuse service, or cancel transactions at its sole discretion.',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    '4. USER CONDUCT',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    'Users of BookBuddies are expected to comply with all applicable laws and regulations, and to respect the rights of other users. Users must not engage in any of the following activities:',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 8.0),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const <Widget>[
                        Text(
                            '- Posting or transmitting any content that is illegal, harmful, threatening, abusive, harassing, defamatory, vulgar, obscene, or invasive of privacy or publicity rights.'),
                        Text(
                            '- Impersonating any person or entity, or falsely stating or otherwise misrepresenting your affiliation with a person or entity. Posting or transmitting any content that infringes on the intellectual property rights of others.'),
                        Text(
                            '- Posting or transmitting any unauthorized advertising, promotional materials, or any other form of solicitation.'),
                        Text(
                            '- Engaging in any activity that could disrupt or interfere with the functioning of the application or its servers.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    '5. LIABILITY DISCLAIMER',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    'BookBuddies is not responsible for any content posted or transmitted by its users, and assumes no responsibility for any errors, omissions, or inaccuracies in such content. BookBuddies makes no representations or warranties of any kind, whether express or implied, regarding the operation of the application or the information, content, materials, or products included on the application.',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    '6. INDEMNIFICATION',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    'Users agree to indemnify and hold BookBuddies, its officers, directors, employees, agents, and affiliates, harmless from any claim or demand, including reasonable attorneys’ fees, made by any third party due to or arising out of their use of the application, their violation of these terms and conditions, or their violation of any rights of another.',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    '7. MODIFICATION OF TERMS',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    'BookBuddies reserves the right to modify or update these terms and conditions at any time, without notice. Users are responsible for regularly reviewing these terms and conditions to ensure their continued compliance.',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    '8. GOVERNING LAW AND JURISDICTION',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    'These terms and conditions shall be governed by and construed in accordance with the laws of the state in which BookBuddies operates. Any legal action or proceeding arising out of these terms and conditions shall be brought in the courts of that state.',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    'By using the BookBuddies application, you agree to be bound by the terms and conditions outlined in this agreement. If you have any questions or concerns, please contact us at support@bookbuddies.com.',
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ])));
  }
}
