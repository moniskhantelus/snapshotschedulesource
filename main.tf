
resource "google_compute_resource_policy" "policy" {
  name    = var.name
  project = var.project_id
  region  = var.region

  snapshot_schedule_policy {
    retention_policy {
      max_retention_days    = var.snapshot_retention_policy.max_retention_days
      on_source_disk_delete = var.snapshot_retention_policy.on_source_disk_delete
    }

    schedule {
      dynamic "daily_schedule" {
        for_each = var.snapshot_schedule.daily_schedule == null ? [] : [var.snapshot_schedule.daily_schedule]
        content {
          days_in_cycle = daily_schedule.value.days_in_cycle
          start_time    = daily_schedule.value.start_time
        }
      }

      dynamic "hourly_schedule" {
        for_each = var.snapshot_schedule.hourly_schedule == null ? [] : [var.snapshot_schedule.hourly_schedule]
        content {
          hours_in_cycle = hourly_schedule.value["hours_in_cycle"]
          start_time     = hourly_schedule.value["start_time"]
        }
      }

      dynamic "weekly_schedule" {
        for_each = var.snapshot_schedule.weekly_schedule == null ? [] : [var.snapshot_schedule.weekly_schedule]
        content {
          dynamic "day_of_weeks" {
            for_each = weekly_schedule.value.day_of_weeks
            content {
              day        = day_of_weeks.value["day"]
              start_time = day_of_weeks.value["start_time"]
            }
          }
        }
      }
    }

    dynamic "snapshot_properties" {
      for_each = var.snapshot_properties == null ? [] : [var.snapshot_properties]
      content {
        guest_flush       = snapshot_properties.value["guest_flush"]
        labels            = snapshot_properties.value["labels"]
        storage_locations = snapshot_properties.value["storage_locations"]
      }
    }
  }

  depends_on = [null_resource.module_depends_on,google_compute_instance.tpl]
}
