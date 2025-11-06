import { DataTypes } from 'sequelize';
import sequelize from '../../db.js';

const Follower = sequelize.define(
  'Follower',
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    followerId: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    followingId: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
  },
  {
    tableName: 'followers',
    timestamps: true,
    updatedAt: false, // Sadece ne zaman oluşturulduğu önemli
    indexes: [
      {
        unique: true,
        fields: ['followerId', 'followingId'],
        name: 'unique_follow', // API Sözleşmesi ile uyumlu index adı
      },
    ],
  }
);
export default Follower;