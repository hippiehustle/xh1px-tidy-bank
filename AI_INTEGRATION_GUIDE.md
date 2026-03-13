# AI Integration Guide - xh1px-tidy-bank
## Intelligent Item Detection & Bank Organization

**Version**: 1.0.0
**Date**: 2025-12-22
**Status**: Implementation Roadmap

---

## 🎯 Executive Summary

This guide outlines how to integrate AI models for:
1. **Computer Vision** - Detect items from screenshots using YOLO/CNN models
2. **Natural Language Processing** - Parse user organization preferences
3. **Optimization AI** - Plan optimal bank layouts using constraint satisfaction
4. **Continuous Learning** - Improve detection accuracy over time

---

## 🧠 Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    AI-Powered Bot Architecture              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐      ┌──────────────┐                   │
│  │ Screenshot   │─────▶│ Vision Model │                   │
│  │ Capture      │      │ (YOLO/CNN)   │                   │
│  └──────────────┘      └──────┬───────┘                   │
│                               │                            │
│                               ▼                            │
│                    ┌──────────────────┐                    │
│                    │ Item Detection   │                    │
│                    │ + Classification │                    │
│                    └──────┬───────────┘                    │
│                           │                                │
│                           ▼                                │
│  ┌──────────────┐      ┌──────────────────┐               │
│  │ User Config  │─────▶│ Optimization AI  │               │
│  │ + NLP Parser │      │ (ML Planner)     │               │
│  └──────────────┘      └──────┬───────────┘               │
│                               │                            │
│                               ▼                            │
│                    ┌──────────────────┐                    │
│                    │ Optimal Layout   │                    │
│                    │ Generator        │                    │
│                    └──────┬───────────┘                    │
│                           │                                │
│                           ▼                                │
│                    ┌──────────────────┐                    │
│                    │ Item Movement    │                    │
│                    │ Execution        │                    │
│                    └──────────────────┘                    │
└─────────────────────────────────────────────────────────────┘
```

---

## 📦 Part 1: AI-Powered Item Detection

### Option A: YOLO (You Only Look Once) - RECOMMENDED

**Why YOLO?**
- Real-time object detection (30-60 FPS)
- Single-pass architecture (fast inference)
- Excellent for small objects (OSRS items)
- Can detect multiple items simultaneously
- Pre-trained models available

**Implementation**:

```python
# ai_detection/yolo_detector.py
import torch
from ultralytics import YOLO
import cv2
import numpy as np
import json

class OSRSItemDetector:
    """
    YOLO-based item detector for OSRS bank screenshots
    """

    def __init__(self, model_path="models/osrs_yolo.pt"):
        """
        Initialize YOLO model

        Args:
            model_path: Path to trained YOLO model weights
        """
        self.model = YOLO(model_path)
        self.item_database = self._load_item_database()

    def _load_item_database(self):
        """Load OSRS item database for name mapping"""
        with open("osrs-items-condensed.json", "r") as f:
            return json.load(f)

    def detect_items(self, screenshot_path):
        """
        Detect all items in bank screenshot

        Args:
            screenshot_path: Path to screenshot file

        Returns:
            List[dict]: Detected items with positions and IDs
            [
                {
                    "id": 1234,
                    "name": "Abyssal whip",
                    "x": 150,
                    "y": 200,
                    "confidence": 0.95,
                    "quantity": 1
                },
                ...
            ]
        """
        # Run YOLO inference
        results = self.model(screenshot_path)

        detected_items = []

        for result in results:
            boxes = result.boxes

            for box in boxes:
                # Extract bounding box coordinates
                x1, y1, x2, y2 = box.xyxy[0].cpu().numpy()
                center_x = int((x1 + x2) / 2)
                center_y = int((y1 + y2) / 2)

                # Get class ID and confidence
                class_id = int(box.cls[0])
                confidence = float(box.conf[0])

                # Map to OSRS item
                if confidence > 0.5:  # Confidence threshold
                    item_data = self._get_item_by_class_id(class_id)

                    detected_items.append({
                        "id": item_data["id"],
                        "name": item_data["name"],
                        "x": center_x,
                        "y": center_y,
                        "confidence": confidence,
                        "quantity": self._detect_quantity(screenshot_path, x1, y1, x2, y2)
                    })

        return detected_items

    def _get_item_by_class_id(self, class_id):
        """Map YOLO class ID to OSRS item"""
        # Class ID should map to item ID
        item_id = str(class_id + 1)  # Adjust offset as needed
        return self.item_database.get(item_id, {"id": 0, "name": "Unknown"})

    def _detect_quantity(self, screenshot, x1, y1, x2, y2):
        """
        Detect item quantity using OCR on the number overlay

        Args:
            screenshot: Screenshot path or numpy array
            x1, y1, x2, y2: Bounding box coordinates

        Returns:
            int: Detected quantity (1 if none detected)
        """
        import pytesseract

        # Load image
        img = cv2.imread(screenshot) if isinstance(screenshot, str) else screenshot

        # Extract quantity region (typically bottom-right of item icon)
        qty_region = img[int(y2-20):int(y2), int(x2-40):int(x2)]

        # Preprocess for OCR
        gray = cv2.cvtColor(qty_region, cv2.COLOR_BGR2GRAY)
        _, thresh = cv2.threshold(gray, 150, 255, cv2.THRESH_BINARY_INV)

        # Run OCR
        text = pytesseract.image_to_string(thresh, config='--psm 7 digits')

        try:
            # Parse quantity
            quantity = int(''.join(filter(str.isdigit, text)))
            return quantity if quantity > 0 else 1
        except:
            return 1

# AutoHotkey Integration Bridge
class AHKBridge:
    """
    Bridge between Python AI model and AutoHotkey bot
    """

    def __init__(self):
        self.detector = OSRSItemDetector()

    def detect_and_save(self, screenshot_path, output_path="ai_detection_results.json"):
        """
        Detect items and save results to JSON for AHK to read

        Args:
            screenshot_path: Path to screenshot
            output_path: Where to save detection results
        """
        items = self.detector.detect_items(screenshot_path)

        # Save to JSON
        with open(output_path, "w") as f:
            json.dump({
                "timestamp": time.time(),
                "items": items,
                "count": len(items)
            }, f, indent=2)

        return items

if __name__ == "__main__":
    import sys

    # Command-line interface for AHK to call
    if len(sys.argv) > 1:
        screenshot_path = sys.argv[1]
        bridge = AHKBridge()
        items = bridge.detect_and_save(screenshot_path)
        print(f"Detected {len(items)} items")
```

**AutoHotkey Integration**:

```autohotkey
; ai_detection.ahk - AI-powered item detection
#Requires AutoHotkey v2.0
#Include constants.ahk
#Include json_parser.ahk

class AIDetector {
    static PYTHON_PATH := "python"
    static DETECTOR_SCRIPT := A_ScriptDir . "\ai_detection\yolo_detector.py"
    static RESULTS_FILE := A_ScriptDir . "\ai_detection_results.json"

    ; Detect items using AI model
    static DetectItems(screenshotPath) {
        try {
            ; Run Python detector
            cmd := this.PYTHON_PATH . ' "' . this.DETECTOR_SCRIPT . '" "' . screenshotPath . '"'
            RunWait(cmd, , "Hide")

            ; Read results
            if FileExist(this.RESULTS_FILE) {
                raw := FileRead(this.RESULTS_FILE)
                results := JSON.Parse(raw)

                ; Convert to AHK format
                items := []
                for index, item in results["items"] {
                    items.Push(Map(
                        "id", item["id"],
                        "name", item["name"],
                        "x", item["x"],
                        "y", item["y"],
                        "confidence", item["confidence"],
                        "quantity", item["quantity"]
                    ))
                }

                Log("AI detected " . items.Length . " items with average confidence " . this._CalcAvgConfidence(items))
                return items
            }

            return []
        } catch as err {
            Log("AI detection error: " . err.Message, LogLevelConstants.ERROR)
            return []
        }
    }

    static _CalcAvgConfidence(items) {
        if (items.Length == 0)
            return 0

        total := 0
        for item in items {
            total += item["confidence"]
        }

        return Round(total / items.Length, 2)
    }
}

; Replace ScanBank() in main.ahk with AI version
ScanBankAI() {
    global screenshot

    if !FileExist(screenshot) {
        return []
    }

    ; Use AI detector
    detectedItems := AIDetector.DetectItems(screenshot)

    ; Convert to bot format
    items := []
    for item in detectedItems {
        items.Push(Map(
            "id", item["id"],
            "x", item["x"],
            "y", item["y"],
            "slot", -1,  ; AI doesn't need slot number
            "confidence", item["confidence"]
        ))
    }

    return items
}
```

---

### Option B: Custom CNN Model

**For more control and customization**:

```python
# ai_detection/custom_cnn.py
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers
import numpy as np

class OSRSItemCNN:
    """
    Custom CNN for OSRS item classification
    """

    def __init__(self, num_classes=24735):
        """
        Initialize CNN model

        Args:
            num_classes: Number of OSRS items (24,735)
        """
        self.model = self._build_model(num_classes)
        self.img_size = (60, 60)  # OSRS item icon size

    def _build_model(self, num_classes):
        """
        Build CNN architecture optimized for small item icons
        """
        model = keras.Sequential([
            # Input layer - 60x60x3 RGB images
            layers.Input(shape=(60, 60, 3)),

            # Convolutional layers
            layers.Conv2D(32, (3, 3), activation='relu', padding='same'),
            layers.BatchNormalization(),
            layers.MaxPooling2D((2, 2)),

            layers.Conv2D(64, (3, 3), activation='relu', padding='same'),
            layers.BatchNormalization(),
            layers.MaxPooling2D((2, 2)),

            layers.Conv2D(128, (3, 3), activation='relu', padding='same'),
            layers.BatchNormalization(),
            layers.MaxPooling2D((2, 2)),

            layers.Conv2D(256, (3, 3), activation='relu', padding='same'),
            layers.BatchNormalization(),
            layers.GlobalAveragePooling2D(),

            # Dense layers
            layers.Dense(512, activation='relu'),
            layers.Dropout(0.5),
            layers.Dense(256, activation='relu'),
            layers.Dropout(0.3),

            # Output layer - softmax for classification
            layers.Dense(num_classes, activation='softmax')
        ])

        model.compile(
            optimizer=keras.optimizers.Adam(learning_rate=0.001),
            loss='sparse_categorical_crossentropy',
            metrics=['accuracy']
        )

        return model

    def detect_item_at_position(self, screenshot, x, y):
        """
        Classify item at given position

        Args:
            screenshot: Full screenshot image (numpy array)
            x, y: Center coordinates of item

        Returns:
            dict: {"item_id": int, "confidence": float}
        """
        # Extract 60x60 region around position
        region = screenshot[y-30:y+30, x-30:x+30]

        # Preprocess
        region = cv2.resize(region, self.img_size)
        region = region / 255.0  # Normalize
        region = np.expand_dims(region, axis=0)

        # Predict
        predictions = self.model.predict(region, verbose=0)
        item_id = np.argmax(predictions[0])
        confidence = predictions[0][item_id]

        return {
            "item_id": int(item_id + 1),  # Adjust for 1-indexed IDs
            "confidence": float(confidence)
        }
```

---

## 🧩 Part 2: NLP-Powered Organization Planning

### Natural Language Configuration Parser

```python
# ai_planning/nlp_config_parser.py
from transformers import pipeline
import json
import re

class BankOrganizerNLP:
    """
    Parse user's natural language organization preferences
    """

    def __init__(self):
        # Load language model for intent classification
        self.classifier = pipeline("zero-shot-classification", model="facebook/bart-large-mnli")

        # Define category mappings
        self.category_keywords = {
            "combat": ["weapon", "armor", "combat", "sword", "bow", "shield"],
            "food": ["food", "fish", "cooking", "eat", "consumable"],
            "potions": ["potion", "flask", "dose", "drink"],
            "resources": ["ore", "bar", "log", "wood", "herb", "seed"],
            "tools": ["pickaxe", "axe", "hammer", "chisel", "tool"],
            "magic": ["rune", "staff", "spell", "magic"],
            "farming": ["seed", "farming", "plant", "grow"],
            "valuable": ["expensive", "valuable", "rare", "high value", "gold"],
        }

    def parse_user_preference(self, user_input):
        """
        Parse natural language organization preference

        Examples:
            "Put all combat gear in tab 1"
            "I want expensive items in the first tab"
            "Keep food and potions separate"
            "Organize by skill: tab 1 mining, tab 2 smithing, tab 3 combat"

        Returns:
            dict: Parsed configuration
        """
        config = {
            "strategy": "auto",
            "tab_assignments": {},
            "rules": []
        }

        # Detect strategy
        if "value" in user_input.lower() or "expensive" in user_input.lower():
            config["strategy"] = "value-based"
        elif "skill" in user_input.lower():
            config["strategy"] = "skill-based"
        elif "category" in user_input.lower() or "type" in user_input.lower():
            config["strategy"] = "category-based"

        # Extract tab assignments
        tab_pattern = r"tab (\d+)[:\s]+([^,\.;]+)"
        matches = re.findall(tab_pattern, user_input.lower())

        for tab_num, description in matches:
            categories = self._classify_description(description)
            config["tab_assignments"][int(tab_num)] = categories

        # Extract separation rules
        if "separate" in user_input.lower():
            separate_pattern = r"(\w+)\s+and\s+(\w+)\s+separate"
            sep_matches = re.findall(separate_pattern, user_input.lower())

            for cat1, cat2 in sep_matches:
                config["rules"].append({
                    "type": "separate",
                    "categories": [cat1, cat2]
                })

        return config

    def _classify_description(self, description):
        """
        Classify description into OSRS categories

        Args:
            description: Natural language description

        Returns:
            list: Matching categories
        """
        categories = []

        # Check against keywords
        for category, keywords in self.category_keywords.items():
            for keyword in keywords:
                if keyword in description:
                    categories.append(category)
                    break

        # Use zero-shot classification if no keyword match
        if not categories:
            candidate_labels = list(self.category_keywords.keys())
            result = self.classifier(description, candidate_labels)

            # Take top 2 categories with >50% confidence
            for label, score in zip(result['labels'], result['scores']):
                if score > 0.5:
                    categories.append(label)

        return categories

# Example usage
if __name__ == "__main__":
    parser = BankOrganizerNLP()

    user_input = """
    I want to organize my bank like this:
    Tab 1: All combat gear and weapons
    Tab 2: Food and potions for bossing
    Tab 3: Expensive items worth over 1M
    Tab 4: Resources like ores and logs
    Keep farming and herblore items separate
    """

    config = parser.parse_user_preference(user_input)
    print(json.dumps(config, indent=2))
```

---

## 🎯 Part 3: AI-Powered Layout Optimization

### Constraint Satisfaction Problem (CSP) Solver

```python
# ai_planning/layout_optimizer.py
from ortools.sat.python import cp_model
import numpy as np

class BankLayoutOptimizer:
    """
    Use Google OR-Tools CP-SAT solver for optimal bank organization
    """

    def __init__(self, items, user_config, item_database):
        """
        Initialize optimizer

        Args:
            items: List of detected items with IDs
            user_config: User preferences from NLP parser
            item_database: OSRS item database with values
        """
        self.items = items
        self.config = user_config
        self.database = item_database
        self.num_tabs = 8
        self.slots_per_tab = 64  # 8x8 grid

    def optimize_layout(self):
        """
        Solve optimal layout using constraint programming

        Returns:
            dict: {tab_number: [list of item IDs]}
        """
        model = cp_model.CpModel()

        # Variables: item_to_tab[item_idx] = tab (0-7)
        item_to_tab = {}
        for idx, item in enumerate(self.items):
            item_to_tab[idx] = model.NewIntVar(0, self.num_tabs - 1, f'item_{idx}_tab')

        # Constraint 1: Tab capacity (64 items per tab)
        for tab in range(self.num_tabs):
            items_in_tab = []
            for idx in range(len(self.items)):
                # Binary: is item in this tab?
                is_in_tab = model.NewBoolVar(f'item_{idx}_in_tab_{tab}')
                model.Add(item_to_tab[idx] == tab).OnlyEnforceIf(is_in_tab)
                model.Add(item_to_tab[idx] != tab).OnlyEnforceIf(is_in_tab.Not())
                items_in_tab.append(is_in_tab)

            # Sum must be <= 64
            model.Add(sum(items_in_tab) <= self.slots_per_tab)

        # Constraint 2: User preferences (hard constraints)
        for tab_num, categories in self.config.get("tab_assignments", {}).items():
            for idx, item in enumerate(self.items):
                item_category = self._get_item_category(item["id"])

                if item_category in categories:
                    # Force this item to assigned tab
                    model.Add(item_to_tab[idx] == tab_num - 1)

        # Constraint 3: Separation rules
        for rule in self.config.get("rules", []):
            if rule["type"] == "separate":
                cat1, cat2 = rule["categories"]

                # Items from cat1 and cat2 must be in different tabs
                for idx1, item1 in enumerate(self.items):
                    for idx2, item2 in enumerate(self.items):
                        if idx1 >= idx2:
                            continue

                        cat_1 = self._get_item_category(item1["id"])
                        cat_2 = self._get_item_category(item2["id"])

                        if cat_1 == cat1 and cat_2 == cat2:
                            model.Add(item_to_tab[idx1] != item_to_tab[idx2])

        # Objective: Minimize tab switches during typical gameplay
        # Strategy 1: Group high-value items
        # Strategy 2: Group frequently used together items

        objective_terms = []

        if self.config.get("strategy") == "value-based":
            # Minimize value variance within tabs
            for tab in range(self.num_tabs):
                tab_value = []
                for idx, item in enumerate(self.items):
                    value = self._get_item_value(item["id"])
                    is_in_tab = model.NewBoolVar(f'obj_item_{idx}_tab_{tab}')
                    model.Add(item_to_tab[idx] == tab).OnlyEnforceIf(is_in_tab)
                    model.Add(item_to_tab[idx] != tab).OnlyEnforceIf(is_in_tab.Not())

                    # Add to objective
                    objective_terms.append(is_in_tab * value)

        # Set objective
        if objective_terms:
            model.Maximize(sum(objective_terms))

        # Solve
        solver = cp_model.CpSolver()
        solver.parameters.max_time_in_seconds = 10.0
        status = solver.Solve(model)

        if status == cp_model.OPTIMAL or status == cp_model.FEASIBLE:
            # Extract solution
            layout = {tab: [] for tab in range(1, self.num_tabs + 1)}

            for idx, item in enumerate(self.items):
                tab = solver.Value(item_to_tab[idx]) + 1  # 1-indexed
                layout[tab].append(item["id"])

            return layout
        else:
            # Fallback: simple greedy assignment
            return self._greedy_fallback()

    def _get_item_category(self, item_id):
        """Get item category from database"""
        item = self.database.get(str(item_id), {})
        # Extract category from item data
        # This would use item_grouping.ahk logic
        return item.get("category", "misc")

    def _get_item_value(self, item_id):
        """Get GE value of item"""
        item = self.database.get(str(item_id), {})
        return item.get("current", {}).get("price", 0)

    def _greedy_fallback(self):
        """Simple greedy assignment if optimization fails"""
        layout = {tab: [] for tab in range(1, self.num_tabs + 1)}
        current_tab = 1
        items_in_tab = 0

        for item in self.items:
            if items_in_tab >= self.slots_per_tab:
                current_tab += 1
                items_in_tab = 0

            layout[current_tab].append(item["id"])
            items_in_tab += 1

        return layout
```

---

## 🔄 Part 4: Continuous Learning System

### Collect User Feedback to Improve AI

```python
# ai_learning/feedback_collector.py
import sqlite3
from datetime import datetime

class FeedbackCollector:
    """
    Collect user feedback to improve AI models
    """

    def __init__(self, db_path="ai_feedback.db"):
        self.conn = sqlite3.connect(db_path)
        self._init_db()

    def _init_db(self):
        """Initialize database tables"""
        self.conn.execute('''
            CREATE TABLE IF NOT EXISTS detection_feedback (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                timestamp DATETIME,
                screenshot_path TEXT,
                predicted_item_id INTEGER,
                actual_item_id INTEGER,
                confidence REAL,
                was_correct BOOLEAN
            )
        ''')

        self.conn.execute('''
            CREATE TABLE IF NOT EXISTS layout_feedback (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                timestamp DATETIME,
                layout_config TEXT,
                user_satisfaction INTEGER,  -- 1-5 rating
                manual_changes INTEGER,  -- How many items user moved
                session_duration_minutes INTEGER
            )
        ''')

        self.conn.commit()

    def record_detection(self, screenshot, predicted_id, actual_id, confidence):
        """Record detection result for training data"""
        self.conn.execute('''
            INSERT INTO detection_feedback
            (timestamp, screenshot_path, predicted_item_id, actual_item_id, confidence, was_correct)
            VALUES (?, ?, ?, ?, ?, ?)
        ''', (
            datetime.now(),
            screenshot,
            predicted_id,
            actual_id,
            confidence,
            predicted_id == actual_id
        ))
        self.conn.commit()

    def get_training_data(self, min_samples=100):
        """
        Get training data for model retraining

        Returns:
            list: Incorrect predictions for focused training
        """
        cursor = self.conn.execute('''
            SELECT screenshot_path, predicted_item_id, actual_item_id, confidence
            FROM detection_feedback
            WHERE was_correct = 0
            ORDER BY timestamp DESC
            LIMIT ?
        ''', (min_samples,))

        return cursor.fetchall()

    def get_accuracy_report(self):
        """Get model accuracy metrics"""
        cursor = self.conn.execute('''
            SELECT
                COUNT(*) as total,
                SUM(CASE WHEN was_correct = 1 THEN 1 ELSE 0 END) as correct,
                AVG(confidence) as avg_confidence
            FROM detection_feedback
            WHERE timestamp > datetime('now', '-7 days')
        ''')

        row = cursor.fetchone()
        if row[0] > 0:
            return {
                "total_detections": row[0],
                "accuracy": row[1] / row[0],
                "avg_confidence": row[2]
            }

        return {"total_detections": 0, "accuracy": 0, "avg_confidence": 0}
```

**AutoHotkey Feedback Integration**:

```autohotkey
; ai_feedback.ahk
class AIFeedback {
    static PYTHON_SCRIPT := A_ScriptDir . "\ai_learning\feedback_collector.py"

    ; User confirms or corrects detection
    static RecordDetection(screenshot, predictedId, actualId, confidence) {
        cmd := 'python "' . this.PYTHON_SCRIPT . '" record ' . screenshot . ' ' . predictedId . ' ' . actualId . ' ' . confidence
        RunWait(cmd, , "Hide")
    }

    ; User rates layout after organization
    static RecordLayoutFeedback(rating, manualChanges) {
        cmd := 'python "' . this.PYTHON_SCRIPT . '" layout ' . rating . ' ' . manualChanges
        RunWait(cmd, , "Hide")
    }
}
```

---

## 🚀 Complete Integration Example

### Full AI-Powered Bot

```autohotkey
; main_ai.ahk - AI-powered version of bot
#Requires AutoHotkey v2.0
#Include constants.ahk
#Include json_parser.ahk
#Include ai_detection.ahk
#Include ai_feedback.ahk

; Override ScanBank() with AI version
ScanBank() {
    global screenshot, cfg

    items := []

    if !FileExist(screenshot) {
        return items
    }

    ; Use AI detection if enabled
    if (cfg["UseAI"]) {
        items := AIDetector.DetectItems(screenshot)
        Log("AI detected " . items.Length . " items", LogLevelConstants.INFO)
    } else {
        ; Fallback to placeholder
        items := ScanBankPlaceholder()
    }

    return items
}

; AI-optimized organization
OptimizeAndOrganize() {
    global cfg

    ; Detect items
    items := ScanBank()

    if (items.Length == 0) {
        return
    }

    ; Get user preferences
    userPref := cfg["OrganizationPreference"]

    ; Run Python optimizer
    RunWait('python ai_planning/layout_optimizer.py "' . userPref . '"', , "Hide")

    ; Read optimal layout
    if FileExist("optimal_layout.json") {
        raw := FileRead("optimal_layout.json")
        layout := JSON.Parse(raw)

        ; Execute layout
        for tabNum, itemIds in layout {
            MoveItemsToTab(itemIds, tabNum)
        }
    }
}
```

---

## 📊 Training the Models

### Data Collection Strategy

```python
# training/data_collection.py

class OSRSDataCollector:
    """
    Collect training data for AI models
    """

    def collect_item_screenshots(self, output_dir="training_data/items"):
        """
        Capture screenshots of all OSRS items for training

        Strategy:
        1. Load OSRS bank with one item type at a time
        2. Screenshot each item in isolation
        3. Label with item ID
        4. Augment with rotations, brightness variations
        """
        import os

        os.makedirs(output_dir, exist_ok=True)

        # This would be run manually:
        # 1. Open OSRS bank
        # 2. Place one item type in specific slot
        # 3. Screenshot
        # 4. Label and save
        # 5. Repeat for all 24,735 items

        # Augmentation
        augmentations = [
            ("brightness_up", lambda img: self._adjust_brightness(img, 1.2)),
            ("brightness_down", lambda img: self._adjust_brightness(img, 0.8)),
            ("contrast", lambda img: self._adjust_contrast(img, 1.3)),
        ]

        print(f"Training data collection guide:")
        print(f"1. Collect 24,735 base screenshots (one per item)")
        print(f"2. Auto-augment to 98,940 images (4x per item)")
        print(f"3. Split: 80% train, 10% validation, 10% test")
        print(f"4. Train YOLO model for 100 epochs")
```

---

## 💡 Recommended Implementation Path

### Phase 1: Basic AI Detection (Week 1-2)
1. Collect 1,000 most common items as training data
2. Train basic CNN or use pre-trained YOLO
3. Achieve 80%+ accuracy on common items
4. Integrate with AutoHotkey via Python bridge

### Phase 2: NLP Config Parser (Week 3)
5. Implement basic keyword matching
6. Test with 10-20 user preference examples
7. Create GUI for natural language input

### Phase 3: Layout Optimizer (Week 4)
8. Implement CSP solver for 8-tab optimization
9. Test with various constraint scenarios
10. Validate optimization quality

### Phase 4: Continuous Learning (Week 5-6)
11. Add feedback collection system
12. Implement model retraining pipeline
13. Deploy improved models weekly

---

## 📈 Expected Performance

| Metric | Target | Notes |
|--------|--------|-------|
| Item Detection Accuracy | >90% | After initial training |
| Detection Speed | <2 seconds | For full 64-slot bank |
| Layout Optimization Time | <5 seconds | CP-SAT solver |
| User Satisfaction | >85% | Based on feedback ratings |
| Model Improvement Rate | +2% per month | With continuous learning |

---

## 🛠️ Required Tools & Libraries

### Python Dependencies
```bash
pip install torch torchvision ultralytics  # YOLO
pip install tensorflow  # CNN option
pip install transformers  # NLP
pip install ortools  # Optimization
pip install opencv-python pytesseract  # Image processing
pip install numpy pandas scikit-learn  # Data science
```

### System Requirements
- **GPU**: NVIDIA GPU with 4GB+ VRAM (recommended for training)
- **RAM**: 16GB+ for model training
- **Storage**: 10GB+ for training data
- **Python**: 3.8+

---

## 🎓 Conclusion

Integrating AI will transform the bot from rule-based to intelligent:

✅ **95%+ detection accuracy** (vs. current placeholder)
✅ **Natural language config** (vs. manual GUI)
✅ **Optimal layouts** (vs. simple category matching)
✅ **Continuous improvement** (vs. static behavior)

**Next Step**: Start with Phase 1 (Basic AI Detection) and iterate from there!

---

**Document Version**: 1.0.0
**Last Updated**: 2025-12-22
**Author**: Claude Code Assistant
**Project**: xh1px-tidy-bank
