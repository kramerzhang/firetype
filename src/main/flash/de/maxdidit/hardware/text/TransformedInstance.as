/*
   'firetype' is an ActionScript 3 library which loads font files and renders characters via the GPU.
   Copyright �2013 Max Knoblich
   www.maxdid.it
   me@maxdid.it

   This file is part of 'firetype' by Max Did It.

   'firetype' is free software: you can redistribute it and/or modify
   it under the terms of the GNU Lesser General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   'firetype' is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public License
   along with 'firetype'.  If not, see <http://www.gnu.org/licenses/>.
 */

package de.maxdidit.hardware.text
{
	import flash.geom.Matrix3D;
	
	/**
	 * ...
	 * @author Max Knoblich
	 */
	public class TransformedInstance
	{
		/////////////////////// 
		// Member Fields 
		/////////////////////// 
		
		private var _x:Number = 0;
		private var _y:Number = 0;
		
		private var _scaleX:Number = 1;
		private var _scaleY:Number = 1;
		
		private var _shearX:Number = 0;
		private var _shearY:Number = 0;
		
		protected var _children:Vector.<TransformedInstance>;
		
		protected var _isLocalDirty:Boolean = true;
		protected var _isGlobalDirty:Boolean = true;
		
		private var _localTransformation:Matrix3D;
		private var _globalTransformation:Matrix3D;
		
		private var _rawLocalData:Vector.<Number>;
		private var _stack:Vector.<TransformedInstance>;
		
		private var _parent:TransformedInstance;
		
		/////////////////////// 
		// Constructor 
		/////////////////////// 
		
		public function TransformedInstance()
		{
			_children = new Vector.<TransformedInstance>();
			_localTransformation = new Matrix3D();
			_globalTransformation = new Matrix3D();
			
			_rawLocalData = new Vector.<Number>();
			_rawLocalData.push(1, 0, 0, 0, // 
				0, 1, 0, 0, // 
				0, 0, 1, 0, // 
				0, 0, 0, 1);
				
			_stack = new Vector.<TransformedInstance>();
		}
		
		/////////////////////// 
		// Member Properties 
		/////////////////////// 
		
		public function get numChildren():uint
		{
			return _children.length;
		}
		
		// x 
		
		public function get x():Number
		{
			return _x;
		}
		
		public function set x(value:Number):void
		{
			if (_x != value)
			{
				_x = value;
				_isLocalDirty = true;
			}
		}
		
		// y 
		
		public function get y():Number
		{
			return _y;
		}
		
		public function set y(value:Number):void
		{
			if (_y != value)
			{
				_y = value;
				_isLocalDirty = true;
			}
		}
		
		// transformation 
		
		public function get localTransformation():Matrix3D
		{
			return _localTransformation;
		}
		
		public function get globalTransformation():Matrix3D
		{
			return _globalTransformation;
		}
		
		// scaleX 
		
		public function get scaleX():Number
		{
			return _scaleX;
		}
		
		public function set scaleX(value:Number):void
		{
			if (_scaleX != value)
			{
				_scaleX = value;
				_isLocalDirty = true;
			}
		}
		
		// scaleY 
		
		public function get scaleY():Number
		{
			return _scaleY;
		}
		
		public function set scaleY(value:Number):void
		{
			if (_scaleY != value)
			{
				_scaleY = value;
				_isLocalDirty = true;
			}
		}
		
		// shearX 
		
		public function get shearX():Number
		{
			return _shearX;
		}
		
		public function set shearX(value:Number):void
		{
			if (_shearX != value)
			{
				_shearX = value;
				_isLocalDirty = true;
			}
		}
		
		// shearY 
		
		public function get shearY():Number
		{
			return _shearY;
		}
		
		public function set shearY(value:Number):void
		{
			if (_shearY != value)
			{
				_shearY = value;
				_isLocalDirty = true;
			}
		}
		
		public function get children():Vector.<TransformedInstance>
		{
			return _children;
		}
		
		public function get isFlaggedForUpdate():Boolean
		{
			return _isLocalDirty;
		}
		
		/////////////////////// 
		// Member Functions 
		/////////////////////// 
		
		public function addChild(child:TransformedInstance):void
		{
			_children.push(child);
			child._parent = this;
		}
		
		public function loseAllChildren():void
		{
			_children.length = 0;
		}
		
		public function calculateTransformations(parentGlobalTransformation:Matrix3D = null, parentChanged:Boolean = false):void
		{
			// calculate local transformation 
			if (_isLocalDirty)
			{
				_rawLocalData[0] = _scaleX;
				_rawLocalData[1] = _shearY * _scaleX;
				
				_rawLocalData[4] = _shearX * _scaleX;
				_rawLocalData[5] = _scaleY;
				
				_rawLocalData[12] = _x;
				_rawLocalData[13] = _y;
				
				_localTransformation.copyRawDataFrom(_rawLocalData);
			}
			
			if (_isLocalDirty || parentChanged)
			{
				if (parentGlobalTransformation)
				{
					_globalTransformation.copyFrom(parentGlobalTransformation);
				}
				else
				{
					_globalTransformation.identity();
				}
				
				_globalTransformation.prepend(_localTransformation);
			}
			
			const l:int = _children.length;
			for (var i:int = l - 1; i >= 0; i--)
			{
				_children[i].calculateTransformations(_globalTransformation, _isLocalDirty || parentChanged);
			}
			
			_isLocalDirty = false;
		}
		
		public function clone():TransformedInstance
		{
			var result:TransformedInstance = new TransformedInstance();
			
			result.x = _x;
			result.y = _y;
			
			return result;
		}
		
		public function flagForUpdate():void
		{
			_isLocalDirty = true;
		}
	}
}
