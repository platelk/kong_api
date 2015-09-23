part of kong;

class NodeStatus {
  int total_requests;
  int connections_active;
  int connections_accepted;
  int connections_writing;
  int connections_waiting;
}