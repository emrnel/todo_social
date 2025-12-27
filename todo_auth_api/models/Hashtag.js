import { DataTypes } from 'sequelize';
import sequelize from '../db.js';

const Hashtag = sequelize.define('Hashtag', {
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true,
  },
  tag: {
    type: DataTypes.STRING(100),
    allowNull: false,
    unique: true,
    comment: 'Hashtag without the # symbol',
  },
  usageCount: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
    comment: 'Number of times this hashtag has been used',
  },
}, {
  tableName: 'hashtags',
  timestamps: true,
});

export default Hashtag;
