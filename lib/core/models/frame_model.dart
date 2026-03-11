class FrameModel {
  String id;
  String name;
  FrameType type;               // vip, svip, event, special
  int tier;
  String imagePath;             // assets/frames/vip_frame1.png
  String? animationPath;        // assets/frames/vip_frame1.json
  bool isAnimated;
  int price;                    // coins
  bool isFree;                  // free from tasks
  String? taskId;               // if free from task
}