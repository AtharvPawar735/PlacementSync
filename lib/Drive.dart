class Drive{

  final int? driveId;
  final String? companyName;
  final String? jobRole;
  final double? ctcLpa;
  final double? minCgpaRequired;
  final String? applicationDeadLine;

  Drive({
    required this.driveId,
    required this.companyName,
    required this.jobRole,
    required this.ctcLpa,
    required this.minCgpaRequired,
    required this.applicationDeadLine
  });


  factory Drive.fromJson(Map<String, dynamic> json) {

    double safeDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0; // Fallback
    }

    return Drive(
      // Change the keys inside the brackets to match your browser JSON exactly!
      driveId: json['id'] ?? json['driveId'] ?? json['drive_id'] ?? 0, 
      companyName: json['company'] ?? json['companyName'] ?? json['company_name'] ?? "Unknown Company", 
      jobRole: json['role'] ?? json['job_role'] ??json['jobRole']?? "Job Role Not Available",
      ctcLpa: safeDouble(json['ctcLpa'] ?? json['ctc'] ?? json['ctc_lpa']),
      
      minCgpaRequired: safeDouble(json['minCgpaRequired'] ?? json['minCgpa'] ?? json['min_cgpa_required']),
      // Ensure deadline is reading the correct key too
      applicationDeadLine: json['deadline'] ?? json['application_deadline'] ?? "Deadline Not Available",
    );
  }

}