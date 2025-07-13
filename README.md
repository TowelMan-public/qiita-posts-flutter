# Qiita Posts (Flutter)

-----

## Overview

This repository serves as a central place for sample code and related resources from my articles published on Qiita. Each article's directory contains the implementation of custom widgets and usage examples as demonstrated in the respective articles.

-----

## Featured Articles and Code

### 1\. Simplify Size Control in Flutter with Custom Flex Widgets\!

  - **Article Link**: [Insert your Qiita article link here] (e.g., `https://qiita.com/TowelMan-public/items/ef338a90edc7fee9e827`)
  - **Code Directory**: `flex_layout/`

This directory contains the source code for a suite of custom "Flex" widgets designed to address common layout challenges in Flutter.

**Key Features**:

  - **FlexLayout**: A foundational layout widget that automatically fits its parent's size and supports `SafeArea` integration.
  - **FlexColum / FlexRow / FlexStack / FlexContainer / FlexSimpleItem / FlexSpacer**: These extend the functionalities of standard Flutter widgets like `Column`, `Row`, `Stack`, `Container`, and `SizedBox`. They offer intuitive size specification using `FlexLayoutConstraints` (with methods like `weight()`, `sideLength()`, and `extend()`), and integrate common decoration and padding features.
  - **FlexLayoutConstraints / FlexLayoutSize**: The core concepts enabling flexible size assignment by combining proportional (`weight`) and fixed (`sideLength`) lengths.
  - **Simplified Global Offset Acquisition**: Utilize `neededOffset: true` to easily retrieve a widget's global coordinates without manual `GlobalKey` management.

-----

## Contribution

Questions, suggestions for improvement, and bug reports are all welcome.
Please use GitHub Issues or Pull Requests.

-----

## License

[Link to your https://www.google.com/search?q=LICENSE file or license information here]
Example: This project is licensed under the MIT License. See the [LICENSE](https://www.google.com/search?q=LICENSE) file for details.

-----

## Author

[Your GitHub Username or Name] - TowelMan

-----
