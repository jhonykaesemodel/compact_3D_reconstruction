function num_anchors = nA_of_cls(class)

switch class
    case 'sofa'
        num_anchors = 5;
    case 'bottle'
        num_anchors = 6;
    case 'aeroplane'
        num_anchors = 6;
    case 'bus'
        num_anchors = 7;
    case 'bicycle'
        num_anchors = 6;
    case 'car'
        num_anchors = 6;
    case 'motorbike'
        num_anchors = 6;
    case 'chair'
        num_anchors = 7;
    otherwise
        num_anchors = 4;
end
