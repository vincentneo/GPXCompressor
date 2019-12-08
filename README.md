# GPXCompressor
Lossy compress your GPX files!

## Compression Methods
To be frank, it is not really a typical file compression, instead, some waypoints are removed throughout the GPX file,
 depending on the method chosen, such that the GPX file is smaller. This is also why its a **lossy** process.
 
After this process, location track data is still preserved, just that its of lower fidelity, as lesser waypoints are kept.

**Current methods include:**
- to remove **duplicate waypoints**
- to remove **nearby waypoints** within a detected radius
- to remove **at random**; % of removal can be selected.

All waypoint types of GPX can be treated, including `waypoint`, `trackpoint` or `routepoint`.

## Description
This project was first created to test [CoreGPX's](https://github.com/vincentneo/CoreGPX) branch [enhancements/56](https://github.com/vincentneo/CoreGPX/pull/63) pull request. 
Throughout testing, I felt that this app could have been useful, hence it ended up being an open-source project of its own.

## Contributing
Contributions to this project will be more than welcomed.
Feel free to add a pull request or open an issue.
If you require a feature that has yet to be available, do open an issue, describing why and what the feature could bring and how it would help you!
