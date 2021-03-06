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
 
package de.maxdidit.hardware.font.data.tables.advanced.gsub.alternate  
{ 
	import de.maxdidit.hardware.font.data.tables.advanced.ScriptFeatureLookupTable; 
	import de.maxdidit.hardware.font.data.tables.common.coverage.ICoverageTable; 
	import de.maxdidit.hardware.font.data.tables.common.lookup.IGlyphLookup; 
	import de.maxdidit.hardware.font.data.tables.common.lookup.ILookupSubtable; 
	import de.maxdidit.hardware.font.data.tables.common.lookup.LookupTable; 
	import de.maxdidit.hardware.font.data.tables.truetype.glyf.Glyph; 
	import de.maxdidit.hardware.font.HardwareFont; 
	import de.maxdidit.hardware.font.parser.tables.TableNames; 
	import de.maxdidit.list.LinkedList; 
	 
	/** 
	 * ... 
	 * @author Max Knoblich 
	 */ 
	public class AlternateSubstitutionSubtable implements ILookupSubtable  
	{ 
		/////////////////////// 
		// Member Fields 
		/////////////////////// 
		 
		private var _coverageOffset:uint; 
		private var _coverage:ICoverageTable; 
		 
		private var _alternateSetCount:uint; 
		private var _alternateSetOffsets:Vector.<uint>; 
		private var _alternateSets:Vector.<AlternateSetTable>; 
		 
		private var _parent:LookupTable; 
		 
		/////////////////////// 
		// Constructor 
		/////////////////////// 
		 
		public function AlternateSubstitutionSubtable()  
		{ 
			 
		} 
		 
		/////////////////////// 
		// Member Properties 
		/////////////////////// 
		 
		public function get coverageOffset():uint  
		{ 
			return _coverageOffset; 
		} 
		 
		public function set coverageOffset(value:uint):void  
		{ 
			_coverageOffset = value; 
		} 
		 
		public function get coverage():ICoverageTable 
		{ 
			return _coverage; 
		} 
		 
		public function set coverage(value:ICoverageTable):void  
		{ 
			_coverage = value; 
		} 
		 
		public function get alternateSetCount():uint  
		{ 
			return _alternateSetCount; 
		} 
		 
		public function set alternateSetCount(value:uint):void  
		{ 
			_alternateSetCount = value; 
		} 
		 
		public function get alternateSetOffsets():Vector.<uint>  
		{ 
			return _alternateSetOffsets; 
		} 
		 
		public function set alternateSetOffsets(value:Vector.<uint>):void  
		{ 
			_alternateSetOffsets = value; 
		} 
		 
		public function get alternateSets():Vector.<AlternateSetTable>  
		{ 
			return _alternateSets; 
		} 
		 
		public function set alternateSets(value:Vector.<AlternateSetTable>):void  
		{ 
			_alternateSets = value; 
		} 
		 
		public function get parent():LookupTable  
		{ 
			return _parent; 
		} 
		 
		public function set parent(value:LookupTable):void  
		{ 
			_parent = value; 
		} 
		 
		/////////////////////// 
		// Member Functions 
		/////////////////////// 
		 
		/* INTERFACE de.maxdidit.hardware.font.data.tables.common.lookup.ILookupSubtable */ 
		 
		public function performLookup(characterInstances:LinkedList, parent:ScriptFeatureLookupTable):void 
		{ 
			throw new Error("Function not yet implemented"); 
		} 
		 
		public function retrieveGlyphLookup(glyphIndex:uint, coverageIndex:int, font:HardwareFont):IGlyphLookup 
		{ 
			var actualCoverageIndex:int = coverageIndex; 
			if (coverageIndex == -1) 
			{ 
				actualCoverageIndex = _coverage.getCoverageIndex(glyphIndex); 
			} 
			 
			var alternateSet:AlternateSetTable = _alternateSets[actualCoverageIndex]; 
			 
			var result:AlternateSubstitutionLookup = new AlternateSubstitutionLookup(); 
			result.alternateSet = alternateSet; 
			 
			return result; 
		} 
		 
		public function resolveDependencies(parent:ScriptFeatureLookupTable, font:HardwareFont):void  
		{ 
			const l:uint = _alternateSetCount; 
			for (var i:uint = 0; i < l; i++) 
			{ 
				var alternateSet:AlternateSetTable = _alternateSets[i]; 
				 
				var gl:uint = alternateSet.glyphCount; 
				var alternateGlyphs:Vector.<Glyph> = new Vector.<Glyph>(gl); 
				for (var g:uint = 0; g < gl; g++) 
				{ 
					alternateGlyphs[g] = font.retrieveGlyph(alternateSet.alternateGlyphIDs[g]); 
				} 
				alternateSet.alternateGlyphs = alternateGlyphs; 
			} 
			 
			// TODO: Fix bug: This should not be null in any case. 
			if (_coverage) 
			{ 
				_coverage.iterateOverCoveredIndices(assignGlyphLookup, font); 
			} 
		} 
		 
		private function assignGlyphLookup(glyphIndex:uint, coverageIndex:uint, font:HardwareFont):void  
		{ 
			var targetGlyph:Glyph = font.retrieveGlyph(glyphIndex); 
			targetGlyph.addGlyphLookup(TableNames.GLYPH_SUBSTITUTION_DATA, _parent.lookupIndex, retrieveGlyphLookup(glyphIndex, coverageIndex, font)); 
		} 
		 
	} 
} 
