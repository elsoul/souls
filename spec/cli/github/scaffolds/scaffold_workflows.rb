module Scaffold
  def self.scaffold_no_workflows
    <<~ONEWORKFLOW
      {
        "total_count": 2,
        "workflow_runs": []
      }
    ONEWORKFLOW
  end

  def self.scaffold_one_workflow
    <<~ONEWORKFLOW
      {
        "total_count": 2,
        "workflow_runs": [
          {
            "id": 11916875,
            "state": "in_progress",
            "name": "Worker"
          },
          {
            "id": 11916875,
            "state": "active",
            "name": "Worker"
          }
        ]
      }
    ONEWORKFLOW
  end

  def self.scaffold_two_workflows
    <<~TWOWORKFLOWS
      {
        "total_count": 2,
        "workflow_runs": [
          {
            "id": 11916874,
            "state": "in_progress",
            "name": "Api"
          },
          {
            "id": 11916875,
            "state": "in_progress",
            "name": "Worker"
          }
        ]
      }
    TWOWORKFLOWS
  end
end
