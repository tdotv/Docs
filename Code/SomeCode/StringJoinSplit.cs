using System;

namespace csharp_station.howto
{
   class StringJoinSplit
   {
       static void Main(string[] args)
       {
            // comma delimited string
            string commaDelimited = "Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec";

           Console.WriteLine("Original Comma Delimited String: \n{0}\n", commaDelimited);

           // separate individual items between commas
            string[] year = commaDelimited.Split(new char[] {','});

           Console.WriteLine("Each individual item: ");

           foreach(string month in year)
           {
                Console.Write("{0} ", month);
           }
           Console.WriteLine("\n");

           // combine array elements with a new separator
            string colonDelimeted = String.Join(":", year);

           Console.WriteLine("New Colon Delimited String: \n{0}\n", colonDelimeted);

           string[] quarter = commaDelimited.Split(new Char[] {','}, 3);

           Console.WriteLine("The First Three Items: ");

           foreach(string month in quarter)
           {
                Console.Write("{0} ", month);
           }
           Console.WriteLine("\n");

           string thirdQuarter = String.Join("/", year, 6, 3);

           Console.WriteLine("The Third Quarter: \n{0}\n", thirdQuarter);
       }
   }
}