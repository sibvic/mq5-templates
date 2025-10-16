# Objects

## IObjectDestructor

Template interface for object destruction and memory management. Used to cleanup visual elements like Box, Line etc from Variable.

## Box

Default implementation of a box.

## BoxesCollection

Collection of boxes. Imitates behavior of PineScript boxes.

## Label

Pine script like implementation of label

## LabelCollection

Manages lifetime of labels

## LinesCollection

Collection of lines. Imitates behavior of PineScript lines.

## Line

Default implementation of a line.

## LinefillsCollection

Collection of linesfilles. Imitates behavior of PineScript linefilles.

## LineFill

Default implementation of a linefill.

## Table

PineScript-like table

## ChartPoint

Base chart point object with reference counting support. Provides basic functionality for chart point management.

## Polyline

Polyline object for drawing trend lines on charts. Manages polyline creation, deletion, and redrawing with reference counting support.

## PolyLinesCollection

Collection manager for polylines with automatic cleanup and memory management. Handles creation, deletion, and organization of polyline objects across multiple collections.