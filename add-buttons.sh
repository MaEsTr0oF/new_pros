#!/bin/bash
# Добавляем кнопки для перемещения анкет перед закрывающим тегом CardActions
sed -i '/<\/CardActions>/i \
                <Tooltip title="Переместить вверх">\n\
                  <IconButton onClick={() => handleMoveUp(profile.id)} size="small">\n\
                    <ArrowUpIcon />\n\
                  </IconButton>\n\
                </Tooltip>\n\
                <Tooltip title="Переместить вниз">\n\
                  <IconButton onClick={() => handleMoveDown(profile.id)} size="small">\n\
                    <ArrowDownIcon />\n\
                  </IconButton>\n\
                </Tooltip>' /root/escort-project/client/src/pages/admin/ProfilesPage.tsx
