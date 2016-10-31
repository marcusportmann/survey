/*
 * Copyright 2016 Marcus Portmann
 * All rights reserved.
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package digital.survey.model;

/**
 * The <code>MailHelperException</code> exception is thrown to indicate an error
 * condition when working with the mail helper.
 *
 * @author Marcus Portmann
 */
public class MailHelperException extends Exception
{
  private static final long serialVersionUID = 1000000;

  /**
   * Constructs a new <code>MailHelperException</code> with the specified message and
   * cause.
   *
   * @param message The message saved for later retrieval by the <code>getMessage()</code> method.
   * @param cause   The cause saved for later retrieval by the <code>getCause()</code> method.
   *                (A <code>null</code> value is permitted if the cause is nonexistent or unknown)
   */
  public MailHelperException(String message, Throwable cause)
  {
    super(message, cause);
  }
}
