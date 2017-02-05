using Microsoft.SqlServer.Server;
using System.Data.SqlTypes;
using System.Text.RegularExpressions;

namespace kuujinbo.SqlClr
{
    public class UDF
    {
        #region regex
        /* #################################################################
         * pass RegexOptions inline:
         * https://msdn.microsoft.com/en-us/library/yd1hzczs.aspx
         * 
         * cannot pass these commonly used values inline:
         * -- RegexOptions.Compiled
         * -- RegexOptions.CultureInvariant
         * #################################################################
         */

        /// <summary>regex match</summary>
        /// <param name="input">input search string</param>
        /// <param name="pattern">regex pattern match</param>
        /// <returns>bool/SQL Server BIT</returns>
        [SqlFunction(
            IsDeterministic = true, IsPrecise = true,
            DataAccess = DataAccessKind.None,
            SystemDataAccess = SystemDataAccessKind.None
        )]
        public static bool RegexMatch(string input, string pattern)
        {
            return Regex.IsMatch(input, pattern, RegexOptions.CultureInvariant);
        }

        /// <summary> regex search/replace</summary>
        /// <param name="input">input search string</param>
        /// <param name="pattern">regex pattern match</param>
        /// <param name="replacement">replacement text</param>
        [SqlFunction(
            IsDeterministic = true, IsPrecise = true,
            DataAccess = DataAccessKind.None,
            SystemDataAccess = SystemDataAccessKind.None
        )]
        public static SqlString RegexReplace(
            string input, string pattern, string replacement
        )
        {
            return Regex.Replace(
                input, pattern, replacement, RegexOptions.CultureInvariant
            );
        }
        #endregion
    }
}