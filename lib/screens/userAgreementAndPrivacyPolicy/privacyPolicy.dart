import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
                'Privacy Policy',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        body: Container(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                  Text(
                    'PRIVACY POLICY',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    "At BookBuddies, we recognize that privacy is important. This Privacy Policy applies to all of the products, services and websites offered by BookBuddies.",
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    "Information we collect:",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    "- Name and Email address when you register for BookBuddies.",
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    "- Location information, when you search for a book.",
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    "How we use the information we collect:",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    "- Provide, maintain, protect and improve our services.",
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    "- Communicate with you to notify about new features, to provide support or to send updates.",
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    "- Understand your needs and preferences, in order to personalize your experience.",
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    "- Comply with any applicable laws or regulations.",
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    "Information we share:",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                      "We do not share any personal information with companies, organizations or individuals outside of BookBuddies unless one of the following circumstances applies:",
                      style: TextStyle(
                        fontSize: 16.0,
                      )),
                  SizedBox(height: 8.0),
                  Text(
                    "- With your consent.",
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  Text(
                    "- To service providers, who work on behalf of BookBuddies and have agreed to abide by the rules set forth in this Privacy Policy.",
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    "For legal reasons:",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                      "We will share personal information with companies, organizations or individuals outside of BookBuddies if we have a good-faith belief that access, use, preservation or disclosure of the information is reasonably necessary to:",
                      style: TextStyle(
                        fontSize: 16.0,
                      )),
                  Text(
                    "- Meet any applicable law, regulation, legal process or enforceable governmental request. Detect, prevent, or otherwise address fraud, security or technical issues.",
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  Text(
                    "- Protect against harm to the rights, property or safety of BookBuddies, our users or the public as required or permitted by law.",
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    "Data Security:",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "- We take appropriate security measures to protect against unauthorized access to or unauthorized alteration, disclosure or destruction of data.",
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    "Changes to this Privacy Policy:",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                      "We reserve the right to update or change our Privacy Policy at any time. If we make any material changes to this Privacy Policy, we will notify you either through the email address you have provided, or by placing a prominent notice on our website.",
                      style: TextStyle(
                        fontSize: 16.0,
                      )),
                  SizedBox(height: 16.0),
                  Text(
                    "Contact Us:",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                      "If you have any questions or concerns about this Privacy Policy, please contact us at support@bookbuddies.com.",
                      style: TextStyle(
                        fontSize: 16.0,
                      )),
                ]))));
  }
}
