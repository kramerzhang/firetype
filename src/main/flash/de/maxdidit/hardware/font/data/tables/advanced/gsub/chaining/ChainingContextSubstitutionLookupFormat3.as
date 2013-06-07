package de.maxdidit.hardware.font.data.tables.advanced.gsub.chaining 
{
	import de.maxdidit.hardware.font.data.tables.advanced.gsub.context.SubstitutionLookupRecord;
	import de.maxdidit.hardware.font.data.tables.common.coverage.ICoverageTable;
	import de.maxdidit.hardware.font.data.tables.common.lookup.IGlyphLookup;
	import de.maxdidit.hardware.text.components.HardwareCharacterInstance;
	import de.maxdidit.list.LinkedList;
	
	/**
	 * ...
	 * @author Max Knoblich
	 */
	public class ChainingContextSubstitutionLookupFormat3 implements IGlyphLookup 
	{
		///////////////////////
		// Member Fields
		///////////////////////
		
		private var _backtackCoverages:Vector.<ICoverageTable>;
		private var _inputCoverages:Vector.<ICoverageTable>;
		private var _lookaheadCoverages:Vector.<ICoverageTable>;
		
		private var _substitutionLookupRecords:Vector.<SubstitutionLookupRecord>;
		private var _substitutionLookups:Vector.<IGlyphLookup>;
		
		///////////////////////
		// Constructor
		///////////////////////
		
		public function ChainingContextSubstitutionLookupFormat3() 
		{
			
		}
		
		///////////////////////
		// Member Properties
		///////////////////////
		
		public function get backtackCoverages():Vector.<ICoverageTable> 
		{
			return _backtackCoverages;
		}
		
		public function set backtackCoverages(value:Vector.<ICoverageTable>):void 
		{
			_backtackCoverages = value;
		}
		
		public function get inputCoverages():Vector.<ICoverageTable> 
		{
			return _inputCoverages;
		}
		
		public function set inputCoverages(value:Vector.<ICoverageTable>):void 
		{
			_inputCoverages = value;
		}
		
		public function get lookaheadCoverages():Vector.<ICoverageTable> 
		{
			return _lookaheadCoverages;
		}
		
		public function set lookaheadCoverages(value:Vector.<ICoverageTable>):void 
		{
			_lookaheadCoverages = value;
		}
		
		public function get substitutionLookupRecords():Vector.<SubstitutionLookupRecord> 
		{
			return _substitutionLookupRecords;
		}
		
		public function set substitutionLookupRecords(value:Vector.<SubstitutionLookupRecord>):void 
		{
			_substitutionLookupRecords = value;
		}
		
		public function get substitutionLookups():Vector.<IGlyphLookup> 
		{
			return _substitutionLookups;
		}
		
		public function set substitutionLookups(value:Vector.<IGlyphLookup>):void 
		{
			_substitutionLookups = value;
		}
		
		///////////////////////
		// Member Functions
		///////////////////////
		
		private function matchBacktrackGlyphs(characterInstances:LinkedList):Boolean 
		{
			var backtrackGlyph:HardwareCharacterInstance = characterInstances.currentElement as HardwareCharacterInstance;
			
			const l:uint = _backtackCoverages.length;
			
			for (var i:uint = 0; i < l; i++)
			{
				backtrackGlyph = backtrackGlyph.previous as HardwareCharacterInstance;
				
				if (!backtrackGlyph)
				{
					return false;
				}
				
				var coverage:ICoverageTable = _backtackCoverages[i];
				var coverageIndex:int = coverage.getCoverageIndex(backtrackGlyph.glyph.header.index);
				
				if (coverageIndex == -1)
				{
					return false;
				}
			}
			
			return true;
		}
		
		private function matchInputGlyphs(characterInstances:LinkedList):Boolean 
		{
			var inputGlyph:HardwareCharacterInstance = characterInstances.currentElement as HardwareCharacterInstance;
			
			const l:uint = _inputCoverages.length;
			
			// start with the next glyph. The first input glyph is automatically matched when the lookup was assigned to this glyph.
			for (var i:uint = 1; i < l; i++)
			{
				inputGlyph = inputGlyph.next as HardwareCharacterInstance;
				
				if (!inputGlyph)
				{
					return false;
				}
				
				var coverage:ICoverageTable = _inputCoverages[i];
				var coverageIndex:int = coverage.getCoverageIndex(inputGlyph.glyph.header.index);
				
				if (coverageIndex == -1)
				{
					return false;
				}
			}
			
			return true;
		}
		
		private function matchLookaheadGlyphs(characterInstances:LinkedList):Boolean 
		{
			var lookaheadGlyph:HardwareCharacterInstance = characterInstances.currentElement as HardwareCharacterInstance;
			var l:uint = _inputCoverages.length;
			// go to end of input glyphs
			for (var i:uint = 1; i < l; i++)
			{
				lookaheadGlyph = lookaheadGlyph.next as HardwareCharacterInstance;
			}
			
			l = _lookaheadCoverages.length;
			
			for (i = 0; i < l; i++)
			{
				lookaheadGlyph = lookaheadGlyph.next as HardwareCharacterInstance;
				
				if (!lookaheadGlyph)
				{
					return false;
				}
				
				var coverage:ICoverageTable = _lookaheadCoverages[i];
				var coverageIndex:int = coverage.getCoverageIndex(lookaheadGlyph.glyph.header.index);
				
				if (coverageIndex == -1)
				{
					return false;
				}
			}
			
			return true;
		}
		
		/* INTERFACE de.maxdidit.hardware.font.data.tables.common.lookup.IGlyphLookup */
		
		public function performLookup(characterInstances:LinkedList):void 
		{
			if (!matchInputGlyphs(characterInstances))
			{
				return;
			}
			
			if (!matchBacktrackGlyphs(characterInstances))
			{
				return;
			}
			
			if (!matchLookaheadGlyphs(characterInstances))
			{
				return;
			}
			
			const l:uint = _substitutionLookups.length;
			for (var i:uint = 0; i < l; i++)
			{
				_substitutionLookups[i].performLookup(characterInstances);
			}
		}
	}

}