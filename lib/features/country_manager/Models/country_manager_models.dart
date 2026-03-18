import '../../../core/models/country_model.dart';


class Country {
  final String id;
  final String name;
  final String flag;
  final String currency;
  final String dialCode;

  Country({
    required this.id,
    required this.name,
    required this.flag,
    required this.currency,
    required this.dialCode,
  });
}

// Manager Status
enum ManagerStatus { active, inactive, pending }
enum IssuePriority { low, medium, high, critical }
enum IssueStatus { open, inProgress, resolved, closed }
enum AgencyRequestStatus { pending, approved, rejected }
enum AgencyStatus { active, inactive, suspended }

class CountryManager {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String countryId;
  final Country? country;
  final DateTime joinedDate;
  final ManagerStatus status;

  // Stats
  final int totalAgencies;
  final int activeAgencies;
  final int pendingAgencies;
  final int totalHosts;
  final int activeHosts;

  // Financial
  final double totalCommission;
  final double monthlyTarget;
  final double achievedTarget;
  final double monthlyEarnings;

  // Performance
  final double agencyGrowthRate;
  final double hostGrowthRate;
  final double revenueGrowthRate;
  final int resolvedIssues;
  final int pendingIssues;

  CountryManager({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.countryId,
    required this.joinedDate,
    required this.status,
    required this.totalAgencies,
    required this.activeAgencies,
    required this.pendingAgencies,
    required this.totalHosts,
    required this.activeHosts,
    required this.totalCommission,
    required this.monthlyTarget,
    required this.achievedTarget,
    required this.monthlyEarnings,
    required this.agencyGrowthRate,
    required this.hostGrowthRate,
    required this.revenueGrowthRate,
    required this.resolvedIssues,
    required this.pendingIssues,
    this.country,
  });

  double get targetProgress => (achievedTarget / monthlyTarget) * 100;
  double get agencyActivationRate => (activeAgencies / totalAgencies) * 100;
  double get hostActivationRate => (activeHosts / totalHosts) * 100;
}

class ManagerAgency {
  final String id;
  final String name;
  final String ownerName;
  final String email;
  final String phone;
  final String address;
  final DateTime registrationDate;
  final AgencyStatus status;
  final bool isVerified;

  // Stats
  final int totalHosts;
  final int activeHosts;
  final double monthlyEarnings;
  final double totalEarnings;
  final double commissionRate;

  // Contact
  final DateTime lastContact;
  final int totalIssues;
  final int resolvedIssues;

  // Performance
  final double monthlyGrowth;
  final List<Host> topHosts;
  final ManagerAgencyStats stats;

  ManagerAgency({
    required this.id,
    required this.name,
    required this.ownerName,
    required this.email,
    required this.phone,
    required this.address,
    required this.registrationDate,
    required this.status,
    required this.isVerified,
    required this.totalHosts,
    required this.activeHosts,
    required this.monthlyEarnings,
    required this.totalEarnings,
    required this.commissionRate,
    required this.lastContact,
    required this.totalIssues,
    required this.resolvedIssues,
    required this.monthlyGrowth,
    required this.topHosts,
    required this.stats,
  });
}

class ManagerAgencyStats {
  final int newHostsThisMonth;
  final int lostHostsThisMonth;
  final double revenueThisMonth;
  final double revenueLastMonth;
  final double growthRate;
  final List<MonthlyData> monthlyData;

  ManagerAgencyStats({
    required this.newHostsThisMonth,
    required this.lostHostsThisMonth,
    required this.revenueThisMonth,
    required this.revenueLastMonth,
    required this.growthRate,
    required this.monthlyData,
  });
}

class MonthlyData {
  final String month;
  final double revenue;
  final int hosts;

  MonthlyData({
    required this.month,
    required this.revenue,
    required this.hosts,
  });
}

class AgencyRecruitmentRequest {
  final String id;
  final String agencyName;
  final String ownerName;
  final String email;
  final String phone;
  final String address;
  final String licenseNumber;
  final String businessPlan;
  final int proposedHosts;
  final double expectedInvestment;
  final DateTime requestDate;
  final AgencyRequestStatus status;
  final String? remarks;
  final String? reviewedBy;
  final DateTime? reviewedDate;

  AgencyRecruitmentRequest({
    required this.id,
    required this.agencyName,
    required this.ownerName,
    required this.email,
    required this.phone,
    required this.address,
    required this.licenseNumber,
    required this.businessPlan,
    required this.proposedHosts,
    required this.expectedInvestment,
    required this.requestDate,
    required this.status,
    this.remarks,
    this.reviewedBy,
    this.reviewedDate,
  });
}

class ManagerIssue {
  final String id;
  final String agencyId;
  final String agencyName;
  final String reportedBy;
  final String reportedById;
  final String title;
  final String description;
  final IssuePriority priority;
  final IssueStatus status;
  final DateTime reportedDate;
  final DateTime? resolvedDate;
  final String? resolution;
  final String? assignedTo;
  final List<String> attachments;
  final List<IssueComment> comments;

  ManagerIssue({
    required this.id,
    required this.agencyId,
    required this.agencyName,
    required this.reportedBy,
    required this.reportedById,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.reportedDate,
    this.resolvedDate,
    this.resolution,
    this.assignedTo,
    this.attachments = const [],
    this.comments = const [],
  });
}

class IssueComment {
  final String id;
  final String userId;
  final String userName;
  final String comment;
  final DateTime date;
  final List<String> attachments;

  IssueComment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.comment,
    required this.date,
    this.attachments = const [],
  });
}

class HostPerformance {
  final String hostId;
  final String name;
  final String username;
  final String? avatar;
  final String agencyId;
  final String agencyName;
  final int followers;
  final int followersGrowth;
  final double monthlyEarnings;
  final double totalEarnings;
  final int totalRooms;
  final int totalHours;
  final double avgRating;
  final int giftsReceived;
  final List<HostEvent> recentEvents;

  HostPerformance({
    required this.hostId,
    required this.name,
    required this.username,
    required this.agencyId,
    required this.agencyName,
    required this.followers,
    required this.followersGrowth,
    required this.monthlyEarnings,
    required this.totalEarnings,
    required this.totalRooms,
    required this.totalHours,
    required this.avgRating,
    required this.giftsReceived,
    required this.recentEvents,
    this.avatar,
  });
}

class HostEvent {
  final String id;
  final String title;
  final DateTime date;
  final int participants;
  final double revenue;
  final String type;

  HostEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.participants,
    required this.revenue,
    required this.type,
  });
}

class Host {
  final String id;
  final String name;
  final String username;

  Host({
    required this.id,
    required this.name,
    required this.username,
  });
}

class ManagerDashboardData {
  final CountryManager manager;
  final List<ManagerAgency> topAgencies;
  final List<HostPerformance> topHosts;
  final List<ManagerIssue> recentIssues;
  final List<AgencyRecruitmentRequest> pendingRequests;
  final Map<String, double> revenueByAgency;
  final Map<String, int> hostsByAgency;

  ManagerDashboardData({
    required this.manager,
    required this.topAgencies,
    required this.topHosts,
    required this.recentIssues,
    required this.pendingRequests,
    required this.revenueByAgency,
    required this.hostsByAgency,
  });
}

// API Models
class UpdateAgencyStatusRequest {
  final String agencyId;
  final AgencyStatus status;
  final String? remark;

  UpdateAgencyStatusRequest({
    required this.agencyId,
    required this.status,
    this.remark,
  });

  Map<String, dynamic> toJson() => {
    'agencyId': agencyId,
    'status': status.toString(),
    'remark': remark,
  };
}

class ResolveIssueRequest {
  final String issueId;
  final String resolution;
  final IssueStatus status;

  ResolveIssueRequest({
    required this.issueId,
    required this.resolution,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
    'issueId': issueId,
    'resolution': resolution,
    'status': status.toString(),
  };
}

class RecruitmentDecisionRequest {
  final String requestId;
  final bool approved;
  final String? remarks;
  final double? commissionRate;

  RecruitmentDecisionRequest({
    required this.requestId,
    required this.approved,
    this.remarks,
    this.commissionRate,
  });

  Map<String, dynamic> toJson() => {
    'requestId': requestId,
    'approved': approved,
    'remarks': remarks,
    'commissionRate': commissionRate,
  };
}