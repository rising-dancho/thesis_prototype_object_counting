import React, { useState, useEffect } from 'react';
import { View, Dimensions, StyleSheet } from 'react-native';
import Svg, { Rect, Text as SvgText } from 'react-native-svg';
import axios from 'axios';

const { width, height } = Dimensions.get('screen');

const scaleBoxCoordinates = (box, imageDimensions) => ({
    x: (box[0] / imageDimensions.width) * width,
    y: (box[1] / imageDimensions.height) * height,
    width: (box[2] / imageDimensions.width) * width,
    height: (box[3] / imageDimensions.height) * height,
});

export default function BoundingBoxes() {
    const [boundingBoxes, setBoundingBoxes] = useState([]);
    const [imageDimensions, setImageDimensions] = useState({ width, height });

    useEffect(() => {
        axios.get('http://localhost:8080/image-processing')
            .then(response => {
                setBoundingBoxes(response.data.bounding_boxes);
                setImageDimensions(response.data.image_dimensions);
            })
            .catch(err => console.error(err));
    }, []);

    return (
        <View style={styles.container}>
            <Svg height={height} width={width} style={styles.svg}>
                {boundingBoxes.map((box, index) => {
                    const scaledBox = scaleBoxCoordinates(box, imageDimensions);
                    return (
                        <React.Fragment key={index}>
                            <Rect
                                x={scaledBox.x}
                                y={scaledBox.y}
                                width={scaledBox.width}
                                height={scaledBox.height}
                                stroke="green"
                                strokeWidth="3"
                                fill="transparent"
                            />
                            <SvgText
                                x={scaledBox.x + scaledBox.width / 2}
                                y={scaledBox.y + scaledBox.height / 2}
                                fill="red"
                                fontSize="20"
                                fontWeight="bold"
                                textAnchor="middle"
                            >
                                {index + 1}
                            </SvgText>
                        </React.Fragment>
                    );
                })}
            </Svg>
        </View>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: '#000',
    },
    svg: {
        position: 'absolute',
        top: 0,
        left: 0,
    },
});
