import Foundation
import UIKit

class ScheduleTableViewController: UITableViewController {
  var coreDataStack: CoreDataStack!
  weak var dataSource: ScheduleDataSource!
  var startDate: NSDate?

  var selectedSession: Session?
  var selectedIndexPath: NSIndexPath?

  var lastSelectedIndexPath: NSIndexPath?

  var isActive = false
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    dataSource = tableView.dataSource! as! ScheduleDataSource
    dataSource.coreDataStack = coreDataStack
    dataSource.startDate = startDate
    if startDate == nil {
      dataSource.endDate = nil
      dataSource.favoritesOnly = true
    } else {
      dataSource.endDate = NSDate(timeInterval: 60*60*24, sinceDate: startDate!)
      dataSource.favoritesOnly = false
    }

    dataSource.tableCellConfigurationBlock = { (cell: ScheduleTableViewCell, indexPath: NSIndexPath, session: Session) -> () in
      let track = session.track.name
      let room = session.room.name
      let sessionNumber = session.sessionNumber

      cell.nameLabel.text = (!self.dataSource.favoritesOnly && session.isFavorite ? "★ " : "") + session.title

      if self.dataSource.favoritesOnly {
        cell.timeLabel.text = "\(session.startTimeString) • \(track) • \(room)"
      } else if sessionNumber != "" {
        cell.timeLabel.text = "\(sessionNumber) • \(track) • \(room)"
      } else {
        cell.timeLabel.text = "\(track) • \(room)"
      }
    }

    let logoImageView = UIImageView(image: UIImage(named: "logo-rwdevcon"))
    logoImageView.translatesAutoresizingMaskIntoConstraints = false
    let header = UIView(frame: CGRect(x: 0, y: 0, width: CGRectGetWidth(view.frame), height: CGRectGetHeight(logoImageView.frame) + 48))
    header.backgroundColor = UIColor(patternImage: UIImage(named: "pattern-grey")!)
    header.addSubview(logoImageView)

    NSLayoutConstraint.activateConstraints([
      NSLayoutConstraint(item: logoImageView, attribute: .CenterX, relatedBy: .Equal, toItem: header, attribute: .CenterX, multiplier: 1.0, constant: 0),
      NSLayoutConstraint(item: logoImageView, attribute: .CenterY, relatedBy: .Equal, toItem: header, attribute: .CenterY, multiplier: 1.0, constant: 0),
      ])

    tableView.tableHeaderView = header

    NSNotificationCenter.defaultCenter().addObserverForName(MyScheduleSomethingChangedNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
      if self.isActive || self.dataSource.favoritesOnly {
        self.refreshSelectively()
      }
    }
  }

  func refreshSelectively() {
    if dataSource.favoritesOnly {
      if let lastSelectedIndexPath = lastSelectedIndexPath {
        if selectedSession != nil && !selectedSession!.isFavorite {
          // selected session is no longer a favorite!
          tableView.reloadData()
          tableFooterOrNot()

          self.selectedSession = nil
          self.selectedIndexPath = nil
          self.lastSelectedIndexPath = nil
          
          if splitViewController != nil {
            if splitViewController!.collapsed {
              navigationController?.popViewControllerAnimated(true)
            } else {
              performSegueWithIdentifier("tableShowDetail", sender: self)
            }
          }
        } else {
          tableView.deselectRowAtIndexPath(lastSelectedIndexPath, animated: true)
        }
      }

      return
    }

    if let selectedIndexPath = selectedIndexPath {
      tableView.reloadSections(NSIndexSet(index: selectedIndexPath.section), withRowAnimation: .None)
    }
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    tableFooterOrNot()

    if splitViewController != nil && !(splitViewController!.collapsed) {
      if selectedIndexPath == nil {
        selectedIndexPath = lastSelectedIndexPath
      }
      if selectedIndexPath == nil && dataSource.allSessions.count > 0 {
        selectedIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        lastSelectedIndexPath = selectedIndexPath
      }

      if selectedIndexPath != nil {
        tableView.selectRowAtIndexPath(selectedIndexPath!, animated: false, scrollPosition: .None)
      }

      performSegueWithIdentifier("tableShowDetail", sender: self)
    }
  }

  func tableFooterOrNot() {
    if !dataSource.favoritesOnly {
      return
    }

    if dataSource.allSessions.count == 0 {
      let footer = UIView(frame: CGRect(x: 0, y: 0, width: CGRectGetWidth(view.frame), height: 500))
      let white = UIView()
      white.translatesAutoresizingMaskIntoConstraints = false
      white.backgroundColor = UIColor.whiteColor()
      white.opaque = true
      footer.addSubview(white)

      let title = UILabel()
      title.translatesAutoresizingMaskIntoConstraints = false
      title.textColor = UIColor(red: 0, green: 109.0/255, blue: 55.0/255, alpha: 1.0)
      title.text = "SCHEDULE EMPTY"
      title.font = UIFont(name: "AvenirNext-Medium", size: 20)
      white.addSubview(title)

      let label = UILabel()
      label.translatesAutoresizingMaskIntoConstraints = false
      label.numberOfLines = 0
      label.textAlignment = .Center
      label.textColor = UIColor.blackColor()
      label.text = "Add talks to your schedule from each talk's detail page:\n\n1.\nFind the talk in the Friday or Saturday tabs.\n\n2.\nTap the talk title to see its detail page.\n\n3.\nTap 'Add to My Schedule'."
      label.font = UIFont(name: "AvenirNext-Regular", size: 19)
      white.addSubview(label)

      let filler = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
      filler.translatesAutoresizingMaskIntoConstraints = false
      white.addSubview(filler)

//      NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[white]|", options: nil, metrics: nil, views: ["white": white]))
//      NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-20-[white]|", options: 0, metrics: nil, views: ["white": white]))

      NSLayoutConstraint.activateConstraints([
        white.leadingAnchor.constraintEqualToAnchor(footer.leadingAnchor),
        white.trailingAnchor.constraintEqualToAnchor(footer.trailingAnchor),
        white.topAnchor.constraintEqualToAnchor(footer.topAnchor, constant: 20),
        white.bottomAnchor.constraintEqualToAnchor(footer.bottomAnchor)
      ])
      
      NSLayoutConstraint.activateConstraints([
        NSLayoutConstraint(item: title, attribute: .CenterX, relatedBy: .Equal, toItem: white, attribute: .CenterX, multiplier: 1.0, constant: 0),
        NSLayoutConstraint(item: label, attribute: .Width, relatedBy: .Equal, toItem: white, attribute: .Width, multiplier: 0.7, constant: 0),
        ])
      NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-20-[title]-20-[label]-20-[filler]", options: .AlignAllCenterX, metrics: nil, views: ["title": title, "label": label, "filler": filler]))

      tableView.tableFooterView = footer
    } else {
      tableView.tableFooterView = nil
    }
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    tableView.reloadData()
  }

  override func willMoveToParentViewController(parent: UIViewController?) {
    super.willMoveToParentViewController(parent)

    tableView.contentInset.bottom = bottomHeight
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let destNav = segue.destinationViewController as? UINavigationController {
      if let dest = destNav.topViewController as? SessionViewController {
        dest.coreDataStack = coreDataStack

        selectedIndexPath = tableView.indexPathForSelectedRow
        lastSelectedIndexPath = tableView.indexPathForSelectedRow
        if selectedIndexPath != nil {
          selectedSession = dataSource.sessionForIndexPath(selectedIndexPath!)
        } else {
          selectedSession = nil
        }
        dest.session = selectedSession
      }
    }
  }

  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 62
  }

  override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 48
  }

  override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let header = UIView(frame: CGRect(x: 0, y: 0, width: CGRectGetWidth(view.bounds), height: 48))
    header.backgroundColor = UIColor(patternImage: UIImage(named: "pattern-row\(section % 2)")!)

    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = dataSource.distinctTimes[section].uppercaseString
    label.textColor = UIColor.whiteColor()
    label.font = UIFont(name: "AvenirNext-Medium", size: 18)
    header.addSubview(label)

//    NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-20-[label]-|", options: nil, metrics: nil, views: ["label": label]) +
//      [NSLayoutConstraint(item: label, attribute: .CenterY, relatedBy: .Equal, toItem: header, attribute: .CenterY, multiplier: 1.0, constant: 4)])
    
    NSLayoutConstraint.activateConstraints([
      label.leadingAnchor.constraintEqualToAnchor(header.leadingAnchor, constant: 20),
      label.trailingAnchor.constraintEqualToAnchor(header.trailingAnchor),
      label.centerYAnchor.constraintEqualToAnchor(header.centerYAnchor, constant: 4)
    ])
    
    return header
  }

  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return UIStatusBarStyle.LightContent
  }

}
