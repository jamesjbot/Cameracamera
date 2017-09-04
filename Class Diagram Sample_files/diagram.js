var entities =
[{
  "id": 1,
  "typeString": "protocol",
  "methods": [
    {
  "name": "displayAlertWindow(title: String, msg: String, actions: [UIAlertAction]?)",
  "type": "instance",
  "accessLevel": "internal"
}
  ],
  "name": "AlertWindowDisplaying",
  "extensions": [
    2
  ]
},{
  "id": 3,
  "typeString": "class",
  "properties": [
    {
  "name": "var window: UIWindow? lazy",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "var persistentContainer: NSPersistentContainer",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "let container",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "let error",
  "type": "instance",
  "accessLevel": "internal"
}
  ],
  "methods": [
    {
  "name": "application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "applicationWillResignActive(_ application: UIApplication)",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "applicationDidEnterBackground(_ application: UIApplication)",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "applicationWillEnterForeground(_ application: UIApplication)",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "applicationDidBecomeActive(_ application: UIApplication)",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "applicationWillTerminate(_ application: UIApplication)",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "saveContext ()",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "init()",
  "type": "instance",
  "accessLevel": "internal"
}
  ],
  "protocols": [
    29
  ],
  "name": "AppDelegate",
  "superClass": 28
},{
  "id": 4,
  "typeString": "protocol",
  "methods": [
    {
  "name": "attachAVCapturePreview(toReceiver: AVCapturePreviewReceiver) -> AVCapturePreviewReceiver?",
  "type": "instance",
  "accessLevel": "internal"
}
  ],
  "name": "AVCapturePreviewProvider"
},{
  "id": 5,
  "typeString": "protocol",
  "methods": [
    {
  "name": "attach(preview videoPreview: AVCaptureVideoPreviewLayer) -> AVCapturePreviewReceiver?",
  "type": "instance",
  "accessLevel": "internal"
}
  ],
  "name": "AVCapturePreviewReceiver"
},{
  "id": 6,
  "typeString": "struct",
  "properties": [
    {
  "name": "let codeType: String",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "let payload: String",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "let origin: CGRect",
  "type": "instance",
  "accessLevel": "internal"
}
  ],
  "methods": [
    {
  "name": "==(lhs: DetectedObjectCharacteristics, rhs: DetectedObjectCharacteristics) -> Bool",
  "type": "type",
  "accessLevel": "internal"
},
    {
  "name": "isSimilar(to rhs: DetectedObjectCharacteristics) -> Bool",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "init(payload: String, origin: CGRect, codeType: String)",
  "type": "instance",
  "accessLevel": "internal"
}
  ],
  "name": "DetectedObjectCharacteristics",
  "superClass": 30
},{
  "id": 7,
  "typeString": "protocol",
  "properties": [
    {
  "name": "var characteristics: DetectedObjectCharacteristics?",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "var keepAlive: Bool",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "var uiViewRepresentation: UIView?",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "var decodedPayload: String",
  "type": "instance",
  "accessLevel": "internal"
}
  ],
  "methods": [
    {
  "name": "isSimilar(toCharacteristics: DetectedObjectCharacteristics) -> Bool",
  "type": "instance",
  "accessLevel": "internal"
}
  ],
  "name": "SelfTerminatingDrawableOutline"
},{
  "id": 8,
  "typeString": "class",
  "properties": [
    {
  "name": "let ORIGIN_MEASUREMENT_ERROR_RANGE",
  "type": "instance",
  "accessLevel": "private"
},
    {
  "name": "let SCREENWIDTH",
  "type": "instance",
  "accessLevel": "private"
},
    {
  "name": "let TIME_TO_KEEP_ALIVE",
  "type": "instance",
  "accessLevel": "fileprivate"
},
    {
  "name": "let viewModelContainingThis: OutlineManager?",
  "type": "instance",
  "accessLevel": "fileprivate"
},
    {
  "name": "var characteristics: DetectedObjectCharacteristics?",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "var creationTime",
  "type": "instance",
  "accessLevel": "fileprivate"
},
    {
  "name": "var decodedPayload: String",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "var description: String",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "let description",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "var hashValue: Int",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "var keepAlive: Bool",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "var timer: Timer?",
  "type": "instance",
  "accessLevel": "fileprivate"
},
    {
  "name": "var uiViewRepresentation: UIView?",
  "type": "instance",
  "accessLevel": "internal"
}
  ],
  "methods": [
    {
  "name": "==(lhs: DetectedObjectOutline, rhs: DetectedObjectOutline) -> Bool",
  "type": "type",
  "accessLevel": "internal"
},
    {
  "name": "init(characteristics: DetectedObjectCharacteristics, viewModel: ViewModel)",
  "type": "instance",
  "accessLevel": "internal"
}
  ],
  "protocols": [
    32
  ],
  "name": "DetectedObjectOutline",
  "superClass": 31,
  "extensions": [
    9
  ]
},{
  "id": 10,
  "typeString": "enum",
  "cases": [
    {
  "name": "CaptureOutputNotOpen case PhotoSampleBufferNil case InitializeCaptureInputError case JPEGPhotoRepresentationError"
}
  ],
  "name": "ModelError",
  "superClass": 33
},{
  "id": 11,
  "typeString": "struct",
  "properties": [
    {
  "name": "var metaDataObject: AVMetadataObject",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "var payload: String",
  "type": "instance",
  "accessLevel": "internal"
}
  ],
  "name": "MetaDataObjectAndPayload"
},{
  "id": 12,
  "typeString": "class",
  "properties": [
    {
  "name": "var currentError: ModelError?",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "var videoPreviewLayer: AVCaptureVideoPreviewLayer?",
  "type": "instance",
  "accessLevel": "fileprivate"
},
    {
  "name": "var metadataCodeObjects",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "var captureSession: AVCaptureSession?",
  "type": "instance",
  "accessLevel": "private"
},
    {
  "name": "var capturePhotoOutput: AVCapturePhotoOutput?",
  "type": "instance",
  "accessLevel": "fileprivate"
},
    {
  "name": "var captureMetaDataOutput: AVCaptureMetadataOutput?",
  "type": "instance",
  "accessLevel": "private"
},
    {
  "name": "var captureDevice: AVCaptureDevice?",
  "type": "instance",
  "accessLevel": "private"
},
    {
  "name": "var captureInput: AVCaptureInput?",
  "type": "instance",
  "accessLevel": "private"
}
  ],
  "methods": [
    {
  "name": "initialize()",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "initializeCaptureInputs()",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "initializeMetaDataCaptureProperties()",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "initializeCaptureOutputs()",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "attachOutputsToCaptureSession()",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "makeVideoPreviewViewLayer() -> AVCaptureVideoPreviewLayer?",
  "type": "instance",
  "accessLevel": "private"
},
    {
  "name": "init()",
  "type": "instance",
  "accessLevel": "internal"
}
  ],
  "name": "Model",
  "superClass": 34,
  "extensions": [
    13,
    14,
    15,
    16
  ]
},{
  "id": 17,
  "typeString": "protocol",
  "properties": [
    {
  "name": "var metadataCodeObjects: MutableObservableArray<MetaDataObjectAndPayload>",
  "type": "instance",
  "accessLevel": "internal"
}
  ],
  "methods": [
    {
  "name": "savePhoto(_ completion: ((Bool)->())?)",
  "type": "instance",
  "accessLevel": "internal"
}
  ],
  "protocols": [
    4
  ],
  "name": "ModelInteractions"
},{
  "id": 18,
  "typeString": "class",
  "properties": [
    {
  "name": "var lastDrawnViews",
  "type": "instance",
  "accessLevel": "public"
},
    {
  "name": "var viewModel: ViewModelInteractions?",
  "type": "instance",
  "accessLevel": "fileprivate"
},
    {
  "name": "var captureVideoPreviewLayer: AVCaptureVideoPreviewLayer?",
  "type": "instance",
  "accessLevel": "fileprivate"
},
    {
  "name": "let weak",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "var previewView: UIView!",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "let weak",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "var onTapTakePhoto: UIButton!",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "let var mainView: UIView!",
  "type": "instance",
  "accessLevel": "internal"
}
  ],
  "methods": [
    {
  "name": "takePhoto(_ sender: Any)",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "viewDidLoad()",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "viewWillAppear(_ animated: Bool)",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "bindViewModel()",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "initializePreviewLayer()",
  "type": "instance",
  "accessLevel": "internal"
}
  ],
  "name": "ViewController",
  "superClass": 35,
  "extensions": [
    20,
    21
  ]
},{
  "id": 19,
  "typeString": "class",
  "methods": [
    {
  "name": "attachViewModel(to viewcontroller: ViewController, viewModel: ViewModelInteractions? = nil) -> ViewController",
  "type": "type",
  "accessLevel": "internal"
}
  ],
  "name": "DependencyInjector"
},{
  "id": 22,
  "typeString": "protocol",
  "methods": [
    {
  "name": "deleteDetectedOutline(_ detectedOuline: SelfTerminatingDrawableOutline) -> Bool",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "getDuplicateOutline(withCharacteristics characteristics: DetectedObjectCharacteristics) -> SelfTerminatingDrawableOutline?",
  "type": "instance",
  "accessLevel": "internal"
}
  ],
  "name": "OutlineManager"
},{
  "id": 23,
  "typeString": "class",
  "properties": [
    {
  "name": "var backingInt",
  "type": "instance",
  "accessLevel": "private"
},
    {
  "name": "var outlineProcessingCycleID: Int",
  "type": "instance",
  "accessLevel": "private"
},
    {
  "name": "var dictionaryOfDistinctStringPayload: [String:[SelfTerminatingDrawableOutline]]",
  "type": "instance",
  "accessLevel": "fileprivate"
},
    {
  "name": "var lastOutlineViews:Observable<[UIView]>",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "var model: ModelInteractions?",
  "type": "instance",
  "accessLevel": "fileprivate"
}
  ],
  "methods": [
    {
  "name": "bindModel()",
  "type": "instance",
  "accessLevel": "private"
},
    {
  "name": "processEveryMetadataObject(objects :[MetaDataObjectAndPayload])",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "createNewOutlineInCollection(withCharacteristics characteristics: DetectedObjectCharacteristics) -> SelfTerminatingDrawableOutline?",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "put(thisNew input: SelfTerminatingDrawableOutline, into dictionaryOfOutlineArrays: [String:[SelfTerminatingDrawableOutline]])",
  "type": "instance",
  "accessLevel": "private"
},
    {
  "name": "init(_ model: ModelInteractions)",
  "type": "instance",
  "accessLevel": "internal"
}
  ],
  "name": "ViewModel",
  "extensions": [
    24,
    25,
    26
  ]
},{
  "id": 27,
  "typeString": "protocol",
  "properties": [
    {
  "name": "var lastOutlineViews: Observable<[UIView]>",
  "type": "instance",
  "accessLevel": "internal"
}
  ],
  "methods": [
    {
  "name": "savePhoto(_ completion: ((Bool)->())?)",
  "type": "instance",
  "accessLevel": "internal"
}
  ],
  "protocols": [
    4
  ],
  "name": "ViewModelInteractions"
},{
  "id": 28,
  "typeString": "class",
  "name": "UIResponder"
},{
  "id": 29,
  "typeString": "protocol",
  "name": "UIApplicationDelegate"
},{
  "id": 30,
  "typeString": "class",
  "name": "Equatable"
},{
  "id": 31,
  "typeString": "class",
  "name": "Hashable"
},{
  "id": 32,
  "typeString": "protocol",
  "name": "CustomStringConvertible"
},{
  "id": 33,
  "typeString": "class",
  "name": "Error"
},{
  "id": 34,
  "typeString": "class",
  "name": "NSObject"
},{
  "id": 35,
  "typeString": "class",
  "name": "UIViewController"
},{
  "id": 36,
  "typeString": "protocol",
  "name": "AVCapturePhotoCaptureDelegate"
},{
  "id": 37,
  "typeString": "protocol",
  "name": "AVCaptureMetadataOutputObjectsDelegate"
},{
  "id": 2,
  "typeString": "extension",
  "methods": [
    {
  "name": "displayAlertWindow(title: String, msg: String, actions: [UIAlertAction]? = nil)",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "dismissAction()-> UIAlertAction",
  "type": "instance",
  "accessLevel": "private"
}
  ]
},{
  "id": 9,
  "typeString": "extension",
  "methods": [
    {
  "name": "isSimilar(toCharacteristics: DetectedObjectCharacteristics) -> Bool",
  "type": "instance",
  "accessLevel": "internal"
}
  ],
  "protocols": [
    7
  ]
},{
  "id": 13,
  "typeString": "extension",
  "methods": [
    {
  "name": "capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?)",
  "type": "instance",
  "accessLevel": "internal"
}
  ],
  "protocols": [
    36
  ]
},{
  "id": 14,
  "typeString": "extension",
  "methods": [
    {
  "name": "captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!)",
  "type": "instance",
  "accessLevel": "internal"
}
  ],
  "protocols": [
    37
  ]
},{
  "id": 15,
  "typeString": "extension",
  "methods": [
    {
  "name": "attachAVCapturePreview(toReceiver: AVCapturePreviewReceiver) -> AVCapturePreviewReceiver?",
  "type": "instance",
  "accessLevel": "internal"
}
  ],
  "protocols": [
    4
  ]
},{
  "id": 16,
  "typeString": "extension",
  "methods": [
    {
  "name": "savePhoto(_ completion: ((Bool)->())? = nil )",
  "type": "instance",
  "accessLevel": "internal"
}
  ],
  "protocols": [
    17
  ]
},{
  "id": 20,
  "typeString": "extension",
  "methods": [
    {
  "name": "display(error: String) -> Bool",
  "type": "instance",
  "accessLevel": "internal"
}
  ],
  "protocols": [
    1
  ]
},{
  "id": 21,
  "typeString": "extension",
  "methods": [
    {
  "name": "attach(preview videoPreview: AVCaptureVideoPreviewLayer) -> AVCapturePreviewReceiver?",
  "type": "instance",
  "accessLevel": "internal"
}
  ],
  "protocols": [
    5
  ]
},{
  "id": 24,
  "typeString": "extension",
  "methods": [
    {
  "name": "attachAVCapturePreview(toReceiver: AVCapturePreviewReceiver) -> AVCapturePreviewReceiver?",
  "type": "instance",
  "accessLevel": "internal"
}
  ],
  "protocols": [
    4
  ]
},{
  "id": 25,
  "typeString": "extension",
  "methods": [
    {
  "name": "savePhoto(_ completion: ((Bool)->())? = nil )",
  "type": "instance",
  "accessLevel": "internal"
}
  ],
  "protocols": [
    27
  ]
},{
  "id": 26,
  "typeString": "extension",
  "methods": [
    {
  "name": "deleteDetectedOutline(_ detectedOuline: SelfTerminatingDrawableOutline) -> Bool",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "getDuplicateOutline(withCharacteristics characteristics: DetectedObjectCharacteristics) -> SelfTerminatingDrawableOutline?",
  "type": "instance",
  "accessLevel": "internal"
}
  ],
  "protocols": [
    22
  ]
}]
;

var renderedEntities = [];

var useCentralNode = true;

var templates = {
  case: undefined,
  property: undefined,
  method: undefined,
  entity: undefined,
  data: undefined,

  setup: function() {
    this.case = document.getElementById("case").innerHTML;
    this.property = document.getElementById("property").innerHTML;
    this.method = document.getElementById("method").innerHTML;
    this.entity = document.getElementById("entity").innerHTML;
    this.data = document.getElementById("data").innerHTML;

    Mustache.parse(this.case)
    Mustache.parse(this.property);
    Mustache.parse(this.method);
    Mustache.parse(this.entity);
    Mustache.parse(this.data);
  }
}

var colorSuperClass = { color: "#848484", highlight: "#848484", hover: "#848484" }
var colorProtocol = { color: "#9a2a9e", highlight: "#9a2a9e", hover: "#9a2a9e" }
var colorExtension = { color: "#2a8e9e", highlight: "#2a8e9e", hover: "#2a8e9e" }
var colorContainedIn = { color: "#99AB22", highlight: "#99AB22", hover: "#99AB22" }
var centralNodeColor = "rgba(0,0,0,0)";
var centralEdgeLengthMultiplier = 1;
var network = undefined;

function bindValues() {
    templates.setup();

    for (var i = 0; i < entities.length; i++) {
        var entity = entities[i];
        var entityToBind = {
            "name": entity.name == undefined ? entity.typeString : entity.name,
            "type": entity.typeString,
            "props": renderTemplate(templates.property, entity.properties),
            "methods": renderTemplate(templates.method, entity.methods),
            "cases": renderTemplate(templates.case, entity.cases)
        };
        var rendered = Mustache.render(templates.entity, entityToBind);
        var txt = rendered;
        document.getElementById("entities").innerHTML += rendered;
    }

    setSize();
    setTimeout(startCreatingDiagram, 100);
}

function renderTemplate(template, list) {
    if (list != undefined && list.length > 0) {
        var result = "";
        for (var i = 0; i < list.length; i++) {
            var temp = Mustache.render(template, list[i]);
            result += temp;
        }
        return result;
    }
    return undefined;
}

function getElementSizes() {
  var strings = [];
  var elements = $("img");

  for (var i = 0; i < elements.length; i++) {
      var element = elements[i];
      
      var elementData = {
        width: element.offsetWidth,
        height: element.offsetHeight
      };
      strings.push(elementData);
  }
  return strings;
}

function renderEntity(index) {
  if (index >= entities.length) {
    // create the diagram
    $("#entities").html("");
    setTimeout(createDiagram, 100);
    return;
  }
  html2canvas($(".entity")[index], {
    onrendered: function(canvas) {
      var data = canvas.toDataURL();
      renderedEntities.push(data);
      var img = Mustache.render(templates.data, {data: data}); 
      $(document.body).append(img);

      renderEntity(index + 1);
    }
  });
}

function startCreatingDiagram() {
  renderedEntities = [];
  renderEntity(0);
}

function createDiagram() {
  var entitySizes = getElementSizes();

  var nodes = [];
  var edges = [];

  var edgesToCentral = [];
  var maxEdgeLength = 0;
  for (var i = 0; i < entities.length; i++) {
    var entity = entities[i];
    var data = entitySizes[i];
    var length = Math.max(data.width, data.height) * 1.5;
    var hasDependencies = false;

    maxEdgeLength = Math.max(maxEdgeLength, length);

    nodes.push({id: entity.id, label: undefined, image: renderedEntities[i], shape: "image", shapeProperties: {useImageSize: true } });
    if (entity.superClass != undefined && entity.superClass > 0) {
      edges.push({from: entity.superClass, to: entity.id, length: length, color: colorSuperClass, label: "inherits", arrows: {from: true} });
      
      hasDependencies = true;
    }

    var extEdges = getEdges(entity.id, entity.extensions, length, "extends", colorExtension, {from: true});
    var proEdges = getEdges(entity.id, entity.protocols, length, "conforms to", colorProtocol, {to: true});
    var conEdges = getEdges(entity.id, entity.containedEntities, length, "contained in", colorContainedIn, {from: true});

    hasDependencies = hasDependencies && extEdges.length > 0 && proEdges.length > 0 && conEdges.length > 0;

    edges = edges.concat(extEdges);
    edges = edges.concat(proEdges);
    edges = edges.concat(conEdges);

    if (!hasDependencies && useCentralNode)
    {
      edgesToCentral.push({from: entity.id, to: -1, length: length * centralEdgeLengthMultiplier, color: centralNodeColor, arrows: {from: true} });
    }
  }

  if (edgesToCentral.length > 1) {
    edges = edges.concat(edgesToCentral);
    nodes.push({id: -1, label: undefined, shape: "circle", color: centralNodeColor });
  }

  var container = document.getElementById("classDiagram");
  var dataToShow = {
      nodes: nodes,
      edges: edges
  };
  var options = {
      "edges": { "smooth": false },
      "physics": {
        "barnesHut": {
          "gravitationalConstant": -7000,
          "springLength": maxEdgeLength,
          "avoidOverlap": 1
        }
      },
      //configure: true
  };
  network = new vis.Network(container, dataToShow, options);

  $("#entities").html("");
  $("img").remove();

  setTimeout(disablePhysics, 200);
}

function disablePhysics()
{
  var options = {
      "edges": { "smooth": false },
      "physics": { "enabled": false }
  };
  network.setOptions(options);
  $(".loading-overlay").fadeOut("fast");
}

function getEdges(entityId, arrayToBind, edgeLength, label, color, arrows) {
  var result = [];
  if (arrayToBind != undefined && arrayToBind.length > 0) {
      for (var i = 0; i < arrayToBind.length; i++) {
        result.push({from: entityId, to: arrayToBind[i], length: edgeLength, color: color, label: label, arrows: arrows });
      }
  }
  return result;   
}

function setSize() {
  var width = $(window).width();
  var height = $(window).height();

  $("#classDiagram").width(width - 5);
  $("#classDiagram").height(height - 5);
}