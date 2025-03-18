import React from 'react';
import { IconButton, Tooltip } from '@mui/material';
import { ArrowUpward as ArrowUpIcon, ArrowDownward as ArrowDownIcon } from '@mui/icons-material';
import { api } from '../../api';

interface ProfileOrderButtonsProps {
  profileId: number;
  onSuccess: () => void;
  onError: (message: string) => void;
}

const ProfileOrderButtons: React.FC<ProfileOrderButtonsProps> = ({ 
  profileId, 
  onSuccess, 
  onError 
}) => {
  const handleMoveUp = async () => {
    try {
      await api.patch(`/admin/profiles/${profileId}/moveUp`);
      onSuccess();
    } catch (error) {
      console.error('Error moving profile up:', error);
      onError('Ошибка при перемещении анкеты вверх');
    }
  };

  const handleMoveDown = async () => {
    try {
      await api.patch(`/admin/profiles/${profileId}/moveDown`);
      onSuccess();
    } catch (error) {
      console.error('Error moving profile down:', error);
      onError('Ошибка при перемещении анкеты вниз');
    }
  };

  return (
    <>
      <Tooltip title="Переместить вверх">
        <IconButton onClick={handleMoveUp} size="small">
          <ArrowUpIcon />
        </IconButton>
      </Tooltip>
      <Tooltip title="Переместить вниз">
        <IconButton onClick={handleMoveDown} size="small">
          <ArrowDownIcon />
        </IconButton>
      </Tooltip>
    </>
  );
};

export default ProfileOrderButtons;
