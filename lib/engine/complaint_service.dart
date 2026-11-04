import 'package:scamshield/engine/models.dart';

class ComplaintService {
  const new _();

  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String scamTypeToEnglish(ScamType type) {
    return switch (type) {
      ScamType.digitalArrest => 'digital arrest',
      ScamType.kycBank => 'KYC/bank',
      ScamType.courierParcel => 'courier/parcel',
      ScamType.traiSim => 'TRAI/SIM',
      ScamType.investment => 'investment',
      ScamType.loanApp => 'loan app',
      ScamType.sextortion => 'sextortion',
      ScamType.familyEmergency => 'family emergency',
      ScamType.none => 'none',
      ScamType.unknown => 'unknown',
    };
  }

  static String _formatTime(double sec) {
    final totalSec = sec.floor();
    final m = (totalSec ~/ 60).toString().padLeft(2, '0');
    final s = (totalSec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  /// Builds a complaint markdown string following the standard template in TESTING.md §4.
  static String build(Verdict verdict, Answers answers, DateTime now) {
    final scamTypeEn = scamTypeToEnglish(verdict.scamType);
    final day = now.day.toString().padLeft(2, '0');
    final month = _months[now.month - 1];
    final year = now.year.toString();
    final dateStr = '$day $month $year';

    final phoneText = verdict.entities.phones.isNotEmpty
        ? verdict.entities.phones.join(', ')
        : 'an unknown number';

    final callerName = verdict.entities.claimedName?.trim().isNotEmpty == true
        ? verdict.entities.claimedName!.trim()
        : '______';

    final callerAgency =
        verdict.entities.claimedAgency?.trim().isNotEmpty == true
        ? verdict.entities.claimedAgency!.trim()
        : '______';

    final caseNoPart = verdict.entities.caseNo?.trim().isNotEmpty == true
        ? ', citing case no. ${verdict.entities.caseNo!.trim()}'
        : '';

    final evidenceLines = verdict.evidence
        .take(6)
        .map((e) => '- [${_formatTime(e.atSec)}] "${e.quote}"')
        .join('\n');

    final amountPart = verdict.entities.amountAsked?.trim().isNotEmpty == true
        ? verdict.entities.amountAsked!.trim()
        : '______';

    final upiPart = verdict.entities.upiIds.isNotEmpty
        ? ' | UPI: ${verdict.entities.upiIds.join(', ')}'
        : '';

    final accountPart = verdict.entities.accounts.isNotEmpty
        ? ' | Account: ${verdict.entities.accounts.join(', ')}'
        : '';

    final moneySent = answers.paid ? 'Yes - UTR/Transaction ID: ______' : 'No';
    final otpShared = answers.sharedCredentials ? 'Yes' : 'No';
    final appShared = answers.remoteApp ? 'Yes' : 'No';

    final buffer = StringBuffer()
      ..writeln('Subject: Suspected $scamTypeEn fraud call on $dateStr')
      ..writeln()
      ..writeln('I received a call from $phoneText on $dateStr.')
      ..writeln(
        'The caller claimed to be $callerName from $callerAgency$caseNoPart.',
      )
      ..writeln()
      ..writeln('What the caller said (from my recording):');

    if (evidenceLines.isNotEmpty) {
      buffer.writeln(evidenceLines);
    }

    buffer
      ..writeln()
      ..writeln('Money/details requested: $amountPart$upiPart$accountPart')
      ..writeln('Money sent by me: $moneySent')
      ..writeln('OTP/PIN/bank details shared: $otpShared')
      ..writeln('Remote-access app installed / screen shared: $appShared')
      ..writeln()
      ..writeln('I request action against the above numbers/accounts.')
      ..writeln('Name: ______   Phone: ______   City/District: ______');

    return buffer.toString().trim();
  }
}
