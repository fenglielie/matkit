针对 `easy_plot` 返回的句柄，可以进行如下调整

|   **操作**    |                         **代码示例**                         |
| :-----------: | :----------------------------------------------------------: |
|   修改颜色    |                  `handles(1).Color = 'r';`                   |
|   修改线型    |                `handles(1).LineStyle = '--';`                |
|   修改线宽    |                 `handles(1).LineWidth = 2;`                  |
|   修改标记    |                  `handles(1).Marker = 'o';`                  |
| 修改标记间隔  |  `handles(1).MarkerIndices = 1:5:length(handles(1).XData);`  |
|   获取数据    |   `x_data = handles(1).XData; y_data = handles(1).YData;`    |
| 隐藏/显示曲线 | `handles(1).Visible = 'off';` / `handles(1).Visible = 'on';` |
|   修改图例    |        `handles(1).DisplayName = 'New Name'; legend;`        |
|   删除曲线    |                    `delete(handles(1));`                     |
|   更新数据    |    `handles(1).XData = new_x; handles(1).YData = new_y;`     |
